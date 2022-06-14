classdef CamAcqWithFrameTimes_2cams < handle
    % Pull in camera data data and save AVI along with a binary file
    % that contains frame times and the number of 2p frames. 
    %
    % Usage:
    % You can run this on a separate machine to the 2p acquisition. 
    % You need to copy the frame trigger to the inputLine, defined below.
    %
    % Format can be:
    %    'Y800 (320x240)','Y800 (640x480)','Y800 (744x480)' 
    %    'RGB24 (320x240)','RGB24 (640x480)','RGB24 (744x480)' 
    % these can be found by "dev_info=imaqhwinfo('tisimaq_r2013_64',1)"
    % Usage example
    % >> V=CamAcqWithFrameTimes('mouse03'); % Start before 2p acq
    % Writing data to 20170817_173541__mouse03
    % delete(V)  %run this when finished
    %
    % Usage example 2
%     >> V1=CamAcqWithFrameTimes_2cams('mouse37_AFTER',1,'Y800 (744x480)'); %wide field
%        V2=CamAcqWithFrameTimes_2cams(V1,2,'Y800 (320x240)'); % eye cam
    % delete(V1);delete(V2)

    properties
        vid % camera object
        frameTimesFname % frame time saved here as a sequence of 32bit integers
        frameTimesFID % handle to binary file
        myTic % Used to keep track of timestamp
        
        mouseName = 'defaultMouse'
        % We will also connect to the DAQ and count frame times
        hTask % DAQ task
        daqDeviceID = 'Dev1'
        inputLine='PFI0' % Connect frame trigger to this line 
        counterID=0
    end

    methods
    
        function obj = CamAcqWithFrameTimes_2cams(INPUT,CamID,Format)
            %Connect to the camera
%             if nargin<2
%                 CamID=1;
%             end
           % obj.vid = videoinput('tisimaq_r2013_64', CamID, 'Y800 (744x480)');
            obj.vid = videoinput('tisimaq_r2013_64', CamID, Format);
            obj.vid.FramesPerTrigger = Inf;
            obj.myTic=tic;

            if ischar(INPUT)
                obj.mouseName = INPUT;
            elseif  isa(INPUT,'CamAcqWithFrameTimes_2cams')
                obj.mouseName = INPUT.mouseName;
                obj.hTask = INPUT.hTask;
            end
            
                % expand to a nice file name
                fName = [datestr(now,'yyyymmdd_HHMMSS__'), obj.mouseName,'_',num2str(CamID)];
                fprintf('Writing data to %s\n', fName)

                % These camera setup lines were generated using imaqtool. 
                obj.vid.LoggingMode = 'disk';
                obj.vid.DiskLogger = VideoWriter([fName,'.avi'], 'Motion JPEG AVI');
                obj.vid.FramesAcquiredFcnCount = 1;
                obj.vid.FramesAcquiredFcn = @obj.frameAcqCallBack;
                
                % Set up timestamp saving
                obj.frameTimesFname = [fName,'_frameTimes.bin'];
                obj.frameTimesFID = fopen(obj.frameTimesFname,'w+');

                % Connect to the DAQ
                %   More details at: "help dabs.ni.daqmx.Task"
                %   C equivalent - DAQmxCreateTask 
                %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
                
                
                if isempty(obj.hTask)
                    try
                        obj.hTask = dabs.ni.daqmx.Task('clk_cam_task2'); % EDIT THIS STRING IF IT'S GRUMPY
                        obj.hTask.createCICountEdgesChan(obj.daqDeviceID, obj.counterID, '', 'DAQmx_Val_CountUp', 'DAQmx_Val_Rising');
                        obj.hTask.channels(1).set('countEdgesTerm',obj.inputLine);
                        obj.hTask.start;
                    catch ME
                        disp(ME.message)
                        fprintf('SHUTTING DOWN')
                        obj.hTask.stop;
                        obj.hTask.delete;
                        delete(obj)
                        return
                    end
                end
            
           start(obj.vid);
           preview(obj.vid)

        end

        function delete(obj)
            stop(obj.vid)
            stoppreview(obj.vid)
            delete(obj.vid)
            fclose(obj.frameTimesFID);

            if isvalid(obj.hTask)
                fprintf('Cleaning up DAQ task\n');
                obj.hTask.stop;
                delete(obj.hTask); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
            else
                fprintf('No DAQmx task available to clean up\n')
            end
        end

        function frameAcqCallBack(obj,~,~)
            % Write time stamp and number of elapsed frames to a binary file.
            % Can be read back by:
            %
            % >> F=fopen('20170817_173222__mouse03_frameTimes.bin','r');
            % >> D=fread(F,'int32');
            % >> fclose(F);
            % >> plot(reshape(D,2,[])

            tmp=toc(obj.myTic)*1E3; %So it's in ms
            fwrite(obj.frameTimesFID, tmp, 'int32'); % Write the time stamp
            fwrite(obj.frameTimesFID, obj.hTask.readCounterDataScalar, 'int32'); % Write the time stamp
            %disp([tmp,obj.hTask.readCounterDataScalar])

        end

        
    end % close methods

end % close clasdef