function MaPlas_2pRAM_viziTK_ATTEN_3patch_aftCovid()

% notes:
% auto reward delay must be more than 100 ms (there is 100 ms input buffer)


close all
clear all
    
global BehCtrl

%--------------Box training mode?
BehCtrl.experimentMode = 1;% default
chooseExperimentMode;% A window will pop up

% 1, box training mode
% 2, macbook coding mode
% 3, 2pRAM recoding mode




%--------------daq device number, ip port
switch BehCtrl.experimentMode
    case 1 
        BehCtrl.DevNum = 'Dev1';
        %BehCtrl.localip = '172.24.170.128';% box 1 (top left)
        %BehCtrl.localip = '172.24.170.141';% box 2 (bottom left)
        %BehCtrl.localip = '172.24.170.123';% box 3 (top right)
        BehCtrl.localip = '172.24.170.135';% box 4 (bottom right)
    case 2
        BehCtrl.DevNum = 'Dev1'; % macbook
        BehCtrl.localip = '10.211.55.3';  
    case 3
        BehCtrl.DevNum = 'Dev3'; % 2pRAM
        BehCtrl.localip = '172.24.170.117';
end


BehCtrl.Vizi.UDPsocket = 25000; % just a random number
BehCtrl.Vizi.UDPUnity = 61557;
BehCtrl.Vizi.sock = pnet('udpsocket',BehCtrl.Vizi.UDPsocket);

BehCtrl.TestMode = false;

% % example command
% pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Ezvz.Vertical);
% pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
BehCtrl.toc = [];

%--------------define state object
BehCtrl.CurrState = BehState_MaPlas;

%--------------initialize params
BehCtrl.GalvoOrIteration = 1;
% 1, galvo
% 2, iteration

% Related to RFMap
BehCtrl.RF.OneCycleDuration = 0.30; % stim duration of either sparse noise or naturalistic images
BehCtrl.RF.StimFlag = 0;        % This is for two stimulus pools to alterate in each trial. Values are 0 or 1.
BehCtrl.RF.Mapping = true;         
BehCtrl.RF.Total = 0; % this is zero to avoid counting the very first RF mapping stimulus (gray without photodiode patch)
BehCtrl.RF.Limit = 20;% when the number of RF shown reaches this value, target stim is triggered. This is updated for every trial.
BehCtrl.RF.iterationNum = 0;
BehCtrl.RF.StimID = 0; % this corresponds to the numbers in a matrix 'orderInSession'
BehCtrl.RF.degMode = 5;

BehCtrl.initializeDone = 0;
BehCtrl.Task.trialNum = 0;
BehCtrl.Task.gotrialnum = 0;
BehCtrl.Task.catchtrialnum = 0;
BehCtrl.Task.nogotrialnum = 0;
BehCtrl.Task.misses = 0;
BehCtrl.Task.falsealarms = 0;
BehCtrl.Task.hits = 0;
BehCtrl.Task.hitCounterForCatch = 0;
BehCtrl.Task.missOnCatch = 0;
BehCtrl.Task.hitOnCatch = 0;
BehCtrl.Task.licked = 0;
BehCtrl.Task.MSRate = [];
BehCtrl.Task.FARate = [];
BehCtrl.Task.earlyEndTrialnum = 0;
BehCtrl.Task.trialID = 0; % Go trials,2; NoGo trials,3;ITI, 4 ; catch, 5
BehCtrl.Task.earlyLickFlag = 0;
BehCtrl.Task.PuffFlag = 0;
BehCtrl.Task.lickIndicatorFlag = 0;
BehCtrl.Task.backgroundStarted = 0;
BehCtrl.Task.ITI = 0; % 1 while ITI is going on
BehCtrl.Task.TargetFlag = 0; % 0/1 flag to decide if digital output is to be sent for getting target onset/offset
BehCtrl.Task.woTarget = 0;
BehCtrl.Task.StimFlag = 1;
BehCtrl.RF.CurrentPhotodiode = 3;
BehCtrl.Task.CurrentPhotodiode = [];
BehCtrl.Task.FirstStimAfterRF = 1;
BehCtrl.ITI.CurrentPhotodiode = 1;
BehCtrl.Task.continuousGo = 0;
BehCtrl.Task.continuousNoGo = 0;
BehCtrl.Task.forceSwitchTrials = 8; % 10000 by default: 'have go at least N trials after the last go' button
BehCtrl.Task.avoidGoTrials = -1; % -1 by default: 'avoid go for N trials after the last go' button
BehCtrl.Task.numMaxIteration = 2;



% Duration of stimulus etc
BehCtrl.Task.StimDuration = 1.6;

% Go target/patch target location
BehCtrl.Task.gngLocation = 1;
BehCtrl.Task.allLocation = 1:2;
% BehCtrl.Task.availableLocation = 2;
BehCtrl.Task.numPatchMode = '2_patch';
BehCtrl.Task.distLocations = setdiff(BehCtrl.Task.allLocation,BehCtrl.Task.gngLocation);% locations for distructor
BehCtrl.Task.angleGo = 0;
BehCtrl.Task.angleNogo = -60;
BehCtrl.Task.removeDistr = false; % distractors are shown by default
BehCtrl.Task.changeTargetLocation = false;
BehCtrl.Task.NumTrialsToChangeTarget = 25; % After this number of trials the location of target pair changes (if BehCtrl.Task.changeTargetLocation = true)
BehCtrl.Task.cumTrialNumAfterChange = 0;
BehCtrl.Task.noiseOnTarget = 0;
BehCtrl.Task.currentNoiseDeg_x = 0;
BehCtrl.Task.currentNoiseDeg_y = 0;
BehCtrl.Task.targetLocations_twoPatch = [360,200;...
                                         120,-200;...
                                         -120,200;...
                                         -360,-200];
BehCtrl.Task.currentShiftingTarget_one = BehCtrl.Task.targetLocations_twoPatch(1,:);                                     
BehCtrl.Task.currentShiftingTarget_two = BehCtrl.Task.targetLocations_twoPatch(3,:);
BehCtrl.Task.currentShiftingTarget_bar = [0,0];
BehCtrl.Task.noisyTargetLocation = false;

% target spatial frequency
BehCtrl.Task.targetSF = 12;
% target size
if BehCtrl.experimentMode == 1
    BehCtrl.Task.Size = 25;
else
    BehCtrl.Task.Size = 16;
end
% target contrast
BehCtrl.Task.targetID_current = [];
BehCtrl.Task.targetID_candidate = 421;

% distructor contrast
BehCtrl.Task.distID_current = 431;
BehCtrl.Task.distID_default = 430; %for setting up default speed (if want to make it slower, change it either to 420 or 410)
BehCtrl.Task.distID_candidate = 431;
BehCtrl.Task.distID_ITI = 431;
BehCtrl.Task.distSF = 24;
BehCtrl.Task.angleDist = 150; % -45 / 45 / 180, or 0 / -60 / 150
BehCtrl.Task.numCycleDist = 0;
BehCtrl.Task.durationDist = BehCtrl.Task.StimDuration;
BehCtrl.Task.countCycleDist = 0;
BehCtrl.Task.numCycleDist = round(BehCtrl.Task.durationDist./BehCtrl.RF.OneCycleDuration);
BehCtrl.Task.temporaryBlockDistr = false; % this is to avoid showing distractor during RF mapping period only on the switching trial

% shift relative angle
BehCtrl.Task.shiftAngle = 0;
BehCtrl.Task.angleGo_original = BehCtrl.Task.angleGo;
BehCtrl.Task.angleNogo_original = BehCtrl.Task.angleNogo;
BehCtrl.Task.angleDist_original = BehCtrl.Task.angleDist;


% show distructor at random timing?
BehCtrl.Task.showITIdistractor = false;
BehCtrl.Task.randomDistProb = 0.02;
BehCtrl.Task.ITIdistONattended = false;% this is if ITI distractor is shown on gng location
BehCtrl.Task.ITIdistSide = 1;% show ITI distractor only on non-attended side

% which elements in a vizi vector to be modified to bring sine wave sheets
% up (this is not used for 1_parch_bar mode)
BehCtrl.Task.tobeBroughtUp = [162,169];% for 4 patch mode

BehCtrl.Task.elements_for_angle = [163,170,177,184,191];
BehCtrl.Task.elements_for_targetID = [159,166,173,180,187];
BehCtrl.Task.elements_for_size = [164,171,178,185,192];
BehCtrl.Task.elements_for_SF = [165,172,179,186,193];

BehCtrl.Task.numHitsBeforecatch = 10; % 10 by default

BehCtrl.Task.showSNonTarget = false;% by default no sparse noises are shown when targets are shown

BehCtrl.Task.stopped = 0;

% related to block structure
BehCtrl.Task.blockCount = NaN;
BehCtrl.Task.blockTrialCount = 0; 
BehCtrl.Task.numBlocks = 2;
BehCtrl.Task.blockSize = 150; % block switches after 150 trials
BehCtrl.Task.BlockActivated = false;
% for time limit
BehCtrl.timeIsOver = false;

%%--------------default params
%--------------New parameters for TAKA gui
% General
if exist('Data','dir')==0
    mkdir Data
end
BehCtrl.Save.Location = strcat(pwd,'\Data');
BehCtrl.Save.MouseID = 'mouse';
BehCtrl.Save.TimeStamp = cell2mat(cellfun(@num2str,num2cell(round(clock)),'un',0));
BehCtrl.Save.TextName = strcat(BehCtrl.Save.Location,'\',...
                               BehCtrl.Save.MouseID,'_RFmap_',...
                               BehCtrl.Save.TimeStamp,...
                               '.txt');  
BehCtrl.Save.metaDataName = [];  
BehCtrl.Save.AI = -1;





% predefined order of LSN stimuli
BehCtrl.LSNvectorLibrary = load('LSNvectorLibrary_ATTEN_5deg.mat','AllvectorsToBeSent','patchMonitorMat','orderInSession');

% size of grating patch in '1_patch_bar' mode
if BehCtrl.experimentMode == 1
    BehCtrl.Bar.holeSize = 5000;
else
    BehCtrl.Bar.holeSize = 4500;
end

% useless area (how many pixels on the edge are not used in 18x32 stim mat)
% 5deg mode
BehCtrl.Vizi.useless_left = 6;  %7 (10deg mode)
BehCtrl.Vizi.useless_right = 4; %4
BehCtrl.Vizi.useless_top = 2;   %2
BehCtrl.Vizi.useless_bottom = 2;%2

% default positions of 2 sine wave grating patches
BehCtrl.Sine.position_one = [280,-265];%[350,-60];%[300,200] in 3 patch mode
BehCtrl.Sine.position_two = [-220,265];%[-220,160];%[-250,200] in 3 patch mode
BehCtrl.Sine.position_three = [25,-300];% this is default position in 3 patch mode
% for avoid zone calculation (used by a function 'sendItBack')
BehCtrl.Task.holePositionMat = cat(1,BehCtrl.Sine.position_one,...
                                     BehCtrl.Sine.position_two);
  
% default color in gui for 4 sine wave grating patches
BehCtrl.Sine.color_one = 'g';
BehCtrl.Sine.color_two = 'm';
BehCtrl.Sine.color_three = 'w';
BehCtrl.Sine.color_bar = 'w';

% default setting
% sheet 1, background
BehCtrl.Vizi.BG1 = 2;% gray
BehCtrl.Vizi.BG2 = 0; %x
BehCtrl.Vizi.BG3 = 0; %y
BehCtrl.Vizi.BG4 = 7;% plane
BehCtrl.Vizi.BG5 = 0; %orientation
BehCtrl.Vizi.BG6 = 30;% size
% sheet 2, grating 1 (for go)
BehCtrl.Vizi.GRone1 = 32; %speed
BehCtrl.Vizi.GRone2 = 0; %x
BehCtrl.Vizi.GRone3 = 0; %y
BehCtrl.Vizi.GRone4 = 10; %plane
BehCtrl.Vizi.GRone5 = BehCtrl.Task.angleGo; % orientation
BehCtrl.Vizi.GRone6 = 35; % size
% sheet 3, grating 2 (for nogo)
BehCtrl.Vizi.GRtwo1 = 32;
BehCtrl.Vizi.GRtwo2 = 0;
BehCtrl.Vizi.GRtwo3 = 0;
BehCtrl.Vizi.GRtwo4 = 11;
BehCtrl.Vizi.GRtwo5 = BehCtrl.Task.angleNogo;
BehCtrl.Vizi.GRtwo6 = 35;
% sheet 4, foreground gray sheet with a hole in the center
BehCtrl.Vizi.FG1 = 20; % shaded hole
BehCtrl.Vizi.FG2 = 0; % x position for top left
BehCtrl.Vizi.FG3 = 0;  % y position for top left
BehCtrl.Vizi.FG4 = 9;  % plane
BehCtrl.Vizi.FG5 = 0;
BehCtrl.Vizi.FG6 = BehCtrl.Bar.holeSize; 
% sheet 5, normal patch but used for photodiode patch
BehCtrl.Vizi.PD1 = 1;%3,white; 1, black; 2, gray
BehCtrl.Vizi.PD2 = 670;
BehCtrl.Vizi.PD3 = -650;
BehCtrl.Vizi.PD4 = 2;
BehCtrl.Vizi.PD5 = 0;
BehCtrl.Vizi.PD6 = 5;% size of photodiode patch
% sheet 6-26, normal patch for sparse noise (common values)
BehCtrl.Vizi.LSN1 = 1;%3,white; 1, black; 2, gray
BehCtrl.Vizi.LSN2 = 0; % x
BehCtrl.Vizi.LSN3 = 0; % y
BehCtrl.Vizi.LSN4 = 4;
BehCtrl.Vizi.LSN5 = 0;
BehCtrl.Vizi.LSN6 = 2.65;
% sheet 27-31, sine wave grating patches (vectors have 7 elements)
     %%%%%%%%%%%%%%%%%% definition of stimulus ID %%%%%%%%%%%%%%%%%%%%%%%%
     % ex) 421
     % - the first value 4 is common
     % - the second value defines the speed (1,2,or 3)
     % - the third value is contrast (1,2,3, or 4)(the higher, the less)
     % Therefore, '421' has a drifting grating at middle speed with 100%
     % contrast.
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BehCtrl.Vizi.sine1 = BehCtrl.Task.distID_default;% stimulus ID (see above for details)
BehCtrl.Vizi.sine2 = 0; % x
BehCtrl.Vizi.sine3 = 0; % y
BehCtrl.Vizi.sine4 = 8; % plane
BehCtrl.Vizi.sine5 = BehCtrl.Task.angleDist; % angle
BehCtrl.Vizi.sine6 = BehCtrl.Task.Size; % size of patch
BehCtrl.Vizi.sine7 = BehCtrl.Task.distSF; % spetial frequency

% visual stimulation by default
BehCtrl.Vizi.background = [BehCtrl.Vizi.BG1,...
                               BehCtrl.Vizi.BG2,...
                               BehCtrl.Vizi.BG3,...
                               BehCtrl.Vizi.BG4,...
                               BehCtrl.Vizi.BG5,...
                               BehCtrl.Vizi.BG6];
BehCtrl.Vizi.grating1 = [BehCtrl.Vizi.GRone1,...
                               BehCtrl.Vizi.GRone2,...
                               BehCtrl.Vizi.GRone3,...
                               BehCtrl.Vizi.GRone4,...
                               BehCtrl.Vizi.GRone5,...
                               BehCtrl.Vizi.GRone6];
BehCtrl.Vizi.grating2 = [BehCtrl.Vizi.GRtwo1,...
                               BehCtrl.Vizi.GRtwo2,...
                               BehCtrl.Vizi.GRtwo3,...
                               BehCtrl.Vizi.GRtwo4,...
                               BehCtrl.Vizi.GRtwo5,...
                               BehCtrl.Vizi.GRtwo6];                           
BehCtrl.Vizi.foreground = [BehCtrl.Vizi.FG1,...
                               BehCtrl.Vizi.FG2,...
                               BehCtrl.Vizi.FG3,...
                               BehCtrl.Vizi.FG4,...
                               BehCtrl.Vizi.FG5,...
                               BehCtrl.Vizi.FG6];
BehCtrl.Vizi.photodiode = [BehCtrl.Vizi.PD1,...
                               BehCtrl.Vizi.PD2,...
                               BehCtrl.Vizi.PD3,...
                               BehCtrl.Vizi.PD4,...
                               BehCtrl.Vizi.PD5,...
                               BehCtrl.Vizi.PD6];
BehCtrl.Vizi.LSNpatch1 = [BehCtrl.Vizi.LSN1,...
                               BehCtrl.Vizi.LSN2,...
                               BehCtrl.Vizi.LSN3,...
                               BehCtrl.Vizi.LSN4,...
                               BehCtrl.Vizi.LSN5,...
                               BehCtrl.Vizi.LSN6];  
BehCtrl.Vizi.sine_one = [BehCtrl.Vizi.sine1,...
                               BehCtrl.Sine.position_one(1),...
                               BehCtrl.Sine.position_one(2),...
                               BehCtrl.Vizi.sine4,...
                               BehCtrl.Vizi.sine5,...
                               BehCtrl.Vizi.sine6,...
                               BehCtrl.Vizi.sine7]; 
BehCtrl.Vizi.sine_two = [BehCtrl.Vizi.sine1,...
                               BehCtrl.Sine.position_two(1),...
                               BehCtrl.Sine.position_two(2),...
                               BehCtrl.Vizi.sine4,...
                               BehCtrl.Vizi.sine5,...
                               BehCtrl.Vizi.sine6,...
                               BehCtrl.Vizi.sine7]; 
BehCtrl.Vizi.sine_three = [BehCtrl.Vizi.sine1,...
                               BehCtrl.Sine.position_three(1),...
                               BehCtrl.Sine.position_three(2),...
                               BehCtrl.Vizi.sine4,...
                               BehCtrl.Vizi.sine5,...
                               BehCtrl.Vizi.sine6,...
                               BehCtrl.Vizi.sine7]; 
                  
                                 
% for gray screen (no PD patch, just whole gray monitor)
BehCtrl.Vizi.bgGray_at_1 = [BehCtrl.Vizi.BG1,...
                               BehCtrl.Vizi.BG2,...
                               BehCtrl.Vizi.BG3,...
                               1,...               % bring it top
                               BehCtrl.Vizi.BG5,...
                               BehCtrl.Vizi.BG6];   
BehCtrl.Vizi.bgGray_at_3 = [BehCtrl.Vizi.BG1,...
                               BehCtrl.Vizi.BG2,...
                               BehCtrl.Vizi.BG3,...
                               3,...               % bring it to 3
                               BehCtrl.Vizi.BG5,...
                               BehCtrl.Vizi.BG6];                           
BehCtrl.Vizi.justGray = cat(2,[0 0],...
                                 BehCtrl.Vizi.bgGray_at_1,...
                                 BehCtrl.Vizi.grating1,...
                                 BehCtrl.Vizi.grating2,...
                                 BehCtrl.Vizi.foreground,...
                                 BehCtrl.Vizi.photodiode,...
                                 repmat(BehCtrl.Vizi.LSNpatch1,1,21),...
                                 repmat(BehCtrl.Vizi.sine_one,1,5));
                                 
BehCtrl.Vizi.justGrayString = mat2str(BehCtrl.Vizi.justGray);

% for ITI gray (with photodiode patch)                      
BehCtrl.Vizi.GrayWithPD = cat(2,[0 0],...
                                 BehCtrl.Vizi.bgGray_at_3,...
                                 BehCtrl.Vizi.grating1,...
                                 BehCtrl.Vizi.grating2,...
                                 BehCtrl.Vizi.foreground,...
                                 BehCtrl.Vizi.photodiode,...
                                 repmat(BehCtrl.Vizi.LSNpatch1,1,21),...
                                 repmat(BehCtrl.Vizi.sine_one,1,5));
                                
BehCtrl.Vizi.GrayWithoutPD = cat(2,[0 0],...
                                 BehCtrl.Vizi.bgGray_at_3,...
                                 BehCtrl.Vizi.grating1,...
                                 BehCtrl.Vizi.grating2,...
                                 BehCtrl.Vizi.foreground,...
                                 [BehCtrl.Vizi.PD1,BehCtrl.Vizi.PD2,BehCtrl.Vizi.PD3,BehCtrl.Vizi.PD4,BehCtrl.Vizi.PD5,0],...
                                 repmat(BehCtrl.Vizi.LSNpatch1,1,21),...
                                 repmat(BehCtrl.Vizi.sine_one,1,5));
                                                          
BehCtrl.Vizi.GrayWithoutPDString = mat2str(BehCtrl.Vizi.GrayWithoutPD);                           
BehCtrl.Vizi.ITIGrayVectorToSend = cat(2,[0 0],...
                                 BehCtrl.Vizi.bgGray_at_3,...
                                 BehCtrl.Vizi.grating1,...
                                 BehCtrl.Vizi.grating2,...
                                 BehCtrl.Vizi.foreground,...
                                 BehCtrl.Vizi.photodiode,...
                                 repmat(BehCtrl.Vizi.LSNpatch1,1,21),...
                                 repmat(BehCtrl.Vizi.sine_one,1,5));
                                 
BehCtrl.Vizi.ITIGrayStringToSend = [];                             
                        
% the very first RF stimuli (at trial zero) is gray screen
BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.Vizi.GrayWithPD;
BehCtrl.Vizi.RFmapVectorToBeSent(27) = BehCtrl.RF.CurrentPhotodiode; % set the photodiode of trial 0 (gray) to be white


% default pixel values
BehCtrl.Vizi.pixelX = 1;
BehCtrl.Vizi.pixelY = 1;

% modify the loaded 3D matrix with default settings
for I = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,1)
    for III = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,3)
        % 5 deg
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,3:8,III) = BehCtrl.Vizi.background;
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,9:14,III) = BehCtrl.Vizi.grating1;
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,15:20,III) = BehCtrl.Vizi.grating2;
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,21:26,III) = BehCtrl.Vizi.foreground;
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,27:32,III) = BehCtrl.Vizi.photodiode;
        % sine waves
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,159:165,III) = BehCtrl.Vizi.sine_one;
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,166:172,III) = BehCtrl.Vizi.sine_two;
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,173:179,III) = BehCtrl.Vizi.sine_three;
        % make target patch bigger
        BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,26,III) = BehCtrl.Bar.holeSize;
    end
end


BehCtrl.Vizi.onepatchUnit_x = abs(BehCtrl.LSNvectorLibrary.patchMonitorMat(1,1,1)-BehCtrl.LSNvectorLibrary.patchMonitorMat(1,2,1))+1;
BehCtrl.Vizi.onepatchUnit_y = abs(BehCtrl.LSNvectorLibrary.patchMonitorMat(1,1,2)-BehCtrl.LSNvectorLibrary.patchMonitorMat(2,1,2))+1;

%----- Related to Rough RF Mapping
BehCtrl.RoughMap.BasicVector = cat(2,[0 0],... 
                                 [1,0,0,2,0,30],...            % background
                                 repmat([0,0,0,8,0,0],1,2),... % grating layers x 2
                                 [20,0,0,1,0,200*BehCtrl.Task.Size],...         % foreground,2700 corresponds to sine patch size of 12.5
                                 [1,670,-650,1,0,5],...        % photodiode patch
                                 repmat([0,0,0,8,0,0],1,21),...
                                 repmat([0,0,0,8,0,0,0],1,5)); % sine patch
                             % for every roughMap stimuli, change the
                             % followings:
                             %   BehCtrl.RoughMap.BasicVector(3) -> 1 or 3 for stimulation, and 2 (gray) for ISI
                             %   BehCtrl.RoughMap.BasicVector(27):photodiode patch color -> 1 (black when stimuli shown), and 2 (gray) when ISI
                             %   BehCtrl.RoughMap.BasicVector(22,23): hole position
        % hole positions  (task) 
        % BehCtrl.Task.holePositionMat,an input for 'sendItBack' can be
        % used : 2019.11.21
        % hole positions for full set of visual stimuli
        BehCtrl.RoughMap.holePosition_full = [-450,450;-450,0;-450,-450;-225,450;-225,0;-225,-450;0,450;0,0;0,-450;225,450;225,0;225,-450;450,450;450,0;450,-450];
        % hole positions for eight visual stimuli
        BehCtrl.RoughMap.holePosition_eight = [-300,240;-300,-240;-67,240;-67,-240;167,240;167,-240;400,240;400,-240];
        % by default task stimuli are used for roughRF mapping
        BehCtrl.RoughMap.taskStim = 1; 
        % BehCtrl.RoughMap.Manual = 0;
        BehCtrl.RoughMap.NumRepeat = 40;
        BehCtrl.RoughMap.StimOrder = []; % this will be updated when Rough RF Mapping start button is pressed (by sendAndUpdateRoughRFMap)


%----- Related to Task
% Duration of gray period (inter-stimuli-interval)
BehCtrl.Task.grayDuration.Min = 3;
BehCtrl.Task.grayDuration.Mean = 12;
BehCtrl.Task.grayDuration.Max = 120;
BehCtrl.Task.DelayTime = 5; % this is duration of RF mapping (will be updated when session starts)



% Task setting
BehCtrl.Task.PuffOnFA = true;          
BehCtrl.Task.earlyLickResetTrial = true;  
BehCtrl.Task.runningTriggerTrials = false; 
BehCtrl.Task.sessionHAStimeLimit = true; % by default this is true and it is set to 65 min (5 min longer than Imaging session)
BehCtrl.Task.ifBlockLFRreward = false;
BehCtrl.Task.AutoRew = true;
BehCtrl.Task.Goprob = 0.5;
BehCtrl.Task.Catchprob = 0.1;
BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.Goprob; % This considers bias 

BehCtrl.Task.bias = 0.1;
BehCtrl.autoRewFlag = 0;
BehCtrl.save.startSaving = 0;       % The data will be saved if this value is one (ie, if '!Save!' button is pressed)
BehCtrl.save.flag = 0;              % everytime '!Save!' button is pressed, this value increments

BehCtrl.RF.fileNumber = 1;

%------------------------------------------


% 
% 
BehCtrl.precision_ms = 20; % speed precision
% lick threshold
switch BehCtrl.experimentMode
    case 1
        BehCtrl.Task.LickThresh = 0.16;
    case 2
        BehCtrl.Task.LickThresh = 10000;
    case 3
        BehCtrl.Task.LickThresh = 0.20;
end
        
BehCtrl.Task.SpeedThresh = 5;
BehCtrl.Task.ValveDuration = 0.30; % in seconds
BehCtrl.Task.AirValveDuration = 0.20; % in seconds
BehCtrl.Task.ifValveOpensWithDelay = 1; % whether valve opens with or w/o delay
BehCtrl.Task.ValveDelay = 0; % delay period between lick detection and puff valve opening. This is StartDelay for the timer BehCtrl.tOpenAirPuffValve
BehCtrl.Task.delayMean = 0.3;% in seconds
BehCtrl.Task.delaySD = 0.03;% in seconds
BehCtrl.Task.delayMin = 0.2;% in seconds
BehCtrl.Task.delayMax = 0.4;% in seconds
BehCtrl.Task.delayDistribution = truncate(makedist('Normal','mu',BehCtrl.Task.delayMean,'sigma',BehCtrl.Task.delaySD),BehCtrl.Task.delayMin,BehCtrl.Task.delayMax);

BehCtrl.Task.sessionTime = 100; % min
BehCtrl.Task.GracePeriod = 0;


BehCtrl.Task.AutoRewDelay = BehCtrl.Task.StimDuration - 0.1;          % Keep the relationship with BehCtrl.Task.StimDuration in mind
BehCtrl.Task.AutoRewValveDuration = 0.05; 



BehCtrl.Task.ITIduration = 2;


BehCtrl.Task.started = false;
BehCtrl.Task.forceGo = false;



%%--------------figures
BehCtrl.handles.f = figure('Units','normalized',...
    'Toolbar','figure','CloseRequestFcn',@my_closefcn);





%%--------------Data
% Title
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text','String','Data',...
        'Position',[0.00,0.9,0.2,0.1],'FontSize',20,'FontWeight','bold','ForegroundColor','blue');
% save location
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.00 0.93 0.10 0.02],'Style','text',...
            'String','Save Location');
    BehCtrl.handles.SaveLocation = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.00 0.88 0.20 0.05],'Style','edit',...
            'String',sprintf('%s',BehCtrl.Save.Location),'Callback',@updateSaveLocation);     
% mouse ID
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.00 0.86 0.10 0.02],'Style','text',...
            'String','mouseID');
    BehCtrl.handles.MouseID = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.00 0.81 0.20 0.05],'Style','edit',...
            'String',sprintf('%s',BehCtrl.Save.MouseID),'Callback',@updateMouseID);        
% split file
    BehCtrl.handles.splitFile = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
            'Position', [0.00 0.78 0.10 0.03],...
            'String','New File','BackgroundColor', 'blue','ForegroundColor','white','enable','on','Callback', @splitFile,'FontWeight','bold');
% start saving
    BehCtrl.handles.startSaving = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
            'Position', [0.10 0.78 0.10 0.03],...
            'String','!Save!','BackgroundColor', 'red','ForegroundColor','white','enable','on','Callback', @startSaving,'FontWeight','bold');
%%-------------------------------------------------------------------------
%%--------------Controls
% Title
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text','String','Controls',...
        'Position',[0.00,0.65,0.2,0.1],'FontSize',20,'FontWeight','bold','ForegroundColor','blue');
% Valve Open (manual)
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
         'Position', [0.00 0.65 0.20 0.05],...
         'String','valveOpen','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @OpenValveManual,'FontWeight','bold');    
% Valve Close (manual)
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
         'Position', [0.00 0.60 0.20 0.05],...
         'String','valveClose ','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @CloseValveManual,'FontWeight','bold');    
% Single Reward (manual)
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
         'Position', [0.00 0.55 0.10 0.05],...
         'String','Single Reward','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @OpenValveRewardManual,'FontWeight','bold');  
% Single Puff (manual)
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
         'Position', [0.10 0.55 0.10 0.05],...
         'String','Single Puff','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @OpenValvePuffManual,'FontWeight','bold');     
% Lick Sensor ON (manual)
    BehCtrl.handles.sensorState = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
         'Position', [0.00 0.50 0.20 0.05],...
         'String','LickSenser ON','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @singleLickShot,'FontWeight','bold');        
% Timer 1
    BehCtrl.handles.timerFirst = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text',...
         'Position',[0.00,0.42,0.1,0.03],...
         'String','00:00:00','BackgroundColor','white');
% Clear button of Timer 1
    BehCtrl.handles.clearTimerFirst = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position',[0.00,0.39,0.1,0.03],...
        'String','clear','enable','on','Callback',@clearTimerFirst);
% Timer 2
    BehCtrl.handles.timerSecond = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text',...
         'Position',[0.1,0.42,0.1,0.03],...
         'String','00:00:00','BackgroundColor','white');
% Clear button of Timer 2
    BehCtrl.handles.clearTimerSecond = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position',[0.1,0.39,0.1,0.03],...
        'String','clear','enable','on','Callback',@clearTimerSecond);     

% Lick Indicator (move to lick plot in future)
    BehCtrl.handles.lickIndicator = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text',...
         'Position', [0.00 0.45 0.20 0.05],...
         'String','','BackgroundColor',[0,0.25,0]);
%%-------------------------------------------------------------------------    
%%--------------RF Mapping
% Title
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text','String','RF Mapping',...
        'Position',[0.00,0.25,0.2,0.1],'FontSize',20,'FontWeight','bold','ForegroundColor','blue');
               
% Rough RF Mapping (Start)
    BehCtrl.handles.roughRFMapping = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0 0.23 0.1 0.04],'Style','pushbutton',...
            'String','Rough RF Mapping','BackgroundColor','green','FontWeight','bold','Callback',@startRoughRFMapping);
% Rough RF Mapping (Number of repetition for each stim location)   
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.1 0.25 0.06 0.02],'Style','edit','Enable','inactive',...
            'String','Repeats','BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white');
    BehCtrl.handles.roughRFMapRepeat = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.16 0.25 0.04 0.02],'Style','edit',...
            'String',sprintf('%s',num2str(BehCtrl.RoughMap.NumRepeat)),'Callback',@changeRoughRFRepeat);        
% Rough RF Mapping (full or only task stimuli; by default, task stimuli)   
    BehCtrl.handles.roughRFMapType = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.1 0.23 0.1 0.02],'Style','popup',...
            'String',{'Task Stimuli','Full Stimuli','Eight Stimuli'},'Callback',@updateRoughRFType);  
% Indicator to show visual stimulation is ON
    BehCtrl.handles.roughRFIndicator = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text',...
         'Position', [0.2 0.23 0.01 0.04],...
         'String','','BackgroundColor',[0,0.25,0]);
% Stimulation type
    BehCtrl.handles.RFStimType = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','popup',...
        'Position', [0.00 0.175 0.20 0.05],...
        'String',{'SparseNoise_5deg','SparseNoise_10deg'},... % By default it is SparseNoise_5deg (changes to Nat.Img if pressed)
        'Callback', @updateRFStimType);  

% RF one cycle duration
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.00 0.125 0.15 0.05],'Style','edit','Enable','inactive',...
            'String','One cycle duration','BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white');
    BehCtrl.handles.RFStimDuration = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.15 0.125 0.05 0.05],'Style','edit',...
            'String',sprintf('%s',num2str(BehCtrl.RF.OneCycleDuration)),'Callback',@changeRFStimDuration);

% RF Mapping Yes or No button  
    BehCtrl.handles.RFMappingONOFF = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
        'Position', [0 0 0.08 0.075],...
        'String','RFMapping ON...','BackgroundColor', 'yellow','Callback', @RFMappingONOFF,'FontWeight','bold');
% Show only RFMapping but not target stimuli  
    BehCtrl.handles.startWOtarget = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.08 0 0.07 0.075],...
        'String','start w/o target','BackgroundColor', 'green','Callback', @startWOtarget,'FontWeight','bold');    
    
% Shuffle order of stimuli button
    BehCtrl.handles.shuffleFileNumber = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.15 0.0375 0.05 0.0375],...
        'String','Shuffle','BackgroundColor', [1,0.4,0.15],'Callback', @shuffleFileNumber,'FontWeight','bold');
% Indicate and/or edit file ID    
    BehCtrl.handles.fileNumber = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit',...
        'Position',[0.15 0 0.05 0.0375],'Callback',@changeFileNumber);
  
%%-------------------------------------------------------------------------
%%--------------Beh State
% Title
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text','String','Beh State',...
        'Position',[0.25,0.9,0.2,0.1],'FontSize',20,'FontWeight','bold','ForegroundColor','blue');
% RFMap Indicator
    BehCtrl.handles.RFMap = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.25 0.88 0.15 0.05],...
        'String','RFMap','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% RF Total Counter
    BehCtrl.handles.RFTotal = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.25 0.83 0.08 0.05],...
        'String',sprintf('Total = %s',num2str(BehCtrl.RF.Total)),'BackgroundColor', [1,1,1],...
        'ForegroundColor',[0.25,0.25,0.25],... % font color
        'enable','off','FontWeight','bold','FontSize',8);    
% Stim ID
    BehCtrl.handles.StimID = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.33 0.83 0.07 0.05],...
        'String',sprintf('%s',num2str(BehCtrl.RF.StimID)),'BackgroundColor', [1,1,1],...
        'ForegroundColor',[0.25,0.25,0.25],... % font color
        'enable','off','FontWeight','bold','FontSize',8);     
% reward zone
    BehCtrl.handles.RewZone = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.4 0.88 0.10 0.05],...
        'String','Reward Zone','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% FA zone
    BehCtrl.handles.PuffZone = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.4 0.83 0.10 0.05],...
        'String','FA Zone','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% ITI
    BehCtrl.handles.ITIZone = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.5 0.83 0.045 0.1],...
        'String','ITI','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);    
% valve
    BehCtrl.handles.Valve = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.55 0.88 0.10 0.05],...
        'String','Valve','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% puff
    BehCtrl.handles.Puff = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.55 0.83 0.10 0.05],...
        'String','Puff','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% new trial
    BehCtrl.handles.NewTrial = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.65 0.83 0.02 0.1],...
        'String','','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',4);
    
% Previous Trial's Delay
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.25 0.78 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','Delay@Previous Trial');
    BehCtrl.handles.previousDelay = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.78 0.07 0.03],'Style','edit',...
        'String','');
% Current Trial's Delay
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.25 0.75 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','Delay@Current Trial');
    BehCtrl.handles.currentDelay = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.75 0.07 0.03],'Style','edit',...
        'String','');  
% Time from Trial Onset
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.25 0.72 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','Current Time');
    BehCtrl.handles.taskCounter = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.72 0.07 0.03],'Style','edit',...
        'String','');  
% Current Go Probability
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.25 0.69 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','Current Go Prob.');
    BehCtrl.handles.currentGoProb = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.69 0.07 0.03],'Style','edit',...
        'String',num2str(BehCtrl.Task.Goprob));     
    
    
% ITI distrubution
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text','Position',[0.55 0.8 0.10 0.03],'String','ITI Distribution','FontWeight','bold');
% Min 
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive','Position',[0.55 0.78 0.07 0.03],'String','Min','FontWeight','bold');
    BehCtrl.handles.grayDuration.Min = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.62 0.78 0.05 0.03],...
    'String',sprintf('%s',num2str(BehCtrl.Task.grayDuration.Min)),'enable','on','Callback', @updateGrayDuration_Min);
% Mean 
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive','Position',[0.55 0.75 0.07 0.03],'String','Mean','FontWeight','bold');
    BehCtrl.handles.grayDuration.Mean = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.62 0.75 0.05 0.03],...
    'String',sprintf('%s',num2str(BehCtrl.Task.grayDuration.Mean)),'enable','on','Callback', @updateGrayDuration_Mean);
% Max (BehCtrl.Task.grayDuration.Min)
    uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive','Position',[0.55 0.72 0.07 0.03],'String','Max','FontWeight','bold');
    BehCtrl.handles.grayDuration.Max = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.62 0.72 0.05 0.03],...
    'String',sprintf('%s',num2str(BehCtrl.Task.grayDuration.Max)),'enable','off','Callback', @updateGrayDuration_Max);
%%-------------------------------------------------------------------------
%%--------------Beh Settings
%---- control of target direction



   
%---- define the number of target patches
BehCtrl.handles.numPatchMode = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','popup',...
    'Position', [0.25 0.66 0.07 0.03],...
    'String',{'3_patch','2_patch','1_patch','1_patch_bar'},... % By default it is 4 patch mode
    'Callback', @updatenumPatchMode); 
     set(BehCtrl.handles.numPatchMode,'Value',2); % 2_patch by default

%---- define the location of Go stimulus
BehCtrl.handles.patchLocation_One = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.33 0.66 0.03 0.03],...
    'String','Go','BackgroundColor', 'green','enable','on','Callback', @go_is_one,'FontWeight','bold');

BehCtrl.handles.patchLocation_Two = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.36 0.66 0.03 0.03],...
    'String','Distractor','BackgroundColor', 'yellow','enable','on','Callback', @go_is_two,'FontWeight','bold');

BehCtrl.handles.patchLocation_Three = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.39 0.66 0.03 0.03],...
    'String','Distractor','BackgroundColor', 'yellow','enable','on','Callback', @go_is_three,'FontWeight','bold');





%---- flash target location (separately)
BehCtrl.handles.flashPatch_One = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.33 0.627 0.03 0.015],...
    'String','flash','BackgroundColor', [0,0.25,0],'ForegroundColor', [1,1,1],'enable','on','Callback', @flashPatch_one,'FontWeight','bold');

BehCtrl.handles.flashPatch_Two = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.36 0.627 0.03 0.015],...
    'String','flash','BackgroundColor', [0,0.25,0],'ForegroundColor', [1,1,1],'enable','on','Callback', @flashPatch_two,'FontWeight','bold');

BehCtrl.handles.flashPatch_Three = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.39 0.627 0.03 0.015],...
    'String','flash','BackgroundColor', [0,0.25,0],'ForegroundColor', [1,1,1],'enable','on','Callback', @flashPatch_three,'FontWeight','bold');


%---- show each target stimulus (separately)
BehCtrl.handles.showPatch_One = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.33 0.645 0.03 0.015],...
    'String','','BackgroundColor', [0,0.25,0],'enable','on','Callback', @showPatch_one,'FontWeight','bold');

BehCtrl.handles.showPatch_Two = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.36 0.645 0.03 0.015],...
    'String','','BackgroundColor', [0,0.25,0],'enable','on','Callback', @showPatch_two,'FontWeight','bold');

BehCtrl.handles.showPatch_Three = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.39 0.645 0.03 0.015],...
    'String','','BackgroundColor', [0,0.25,0],'enable','on','Callback', @showPatch_three,'FontWeight','bold');





%---- set angle of go and nogo stimuli
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.25 0.65 0.075 0.02],'Style','edit','Enable','inactive',...
    'String','Target Angle');
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','green','ForegroundColor','black','FontWeight','bold','Units','normalized',...
    'Position',[0.25 0.63 0.025 0.02],'Style','edit','Enable','inactive',...
    'String','Go');
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','magenta','ForegroundColor','black','FontWeight','bold','Units','normalized',...
    'Position',[0.275 0.63 0.025 0.02],'Style','edit','Enable','inactive',...
    'String','Nogo');
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','black','ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.3 0.63 0.025 0.02],'Style','edit','Enable','inactive',...
    'String','Dist');
BehCtrl.handles.angleGo = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','popup',...
    'Position', [0.25 0.60 0.025 0.03],...
    'String',{'-60','-45','-30','-15','0','15','30','45','60'},... 
    'Callback', @updateangleGo); 
    set(BehCtrl.handles.angleGo,'Value',5);% 0 deg by default
BehCtrl.handles.angleNogo = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','popup',...
    'Position', [0.275 0.60 0.025 0.03],...
    'String',{'-60','-45','-30','-15','0','15','30','45','60'},... 
    'Callback', @updateangleNogo); 
    set(BehCtrl.handles.angleNogo,'Value',1);% -60 deg by default
BehCtrl.handles.angleDist = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','popup',...
    'Position', [0.3 0.60 0.025 0.03],...
    'String',{'-180','-165','-150','-135','-120','-105','-90','-75','-60','-45','-30','-15','0','15','30','45','60','75','90','105','120','135','150','165','180'},... 
    'Callback', @updateangleDist); 
    set(BehCtrl.handles.angleDist,'Value',23);% 150 deg by default
    
%---- set spatial frequency of go and nogo stimuli 
% (Target)
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.25 0.55 0.07 0.02],'Style','edit','Enable','inactive',...
    'String','Target SF');    
BehCtrl.handles.slider_targetSF = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
        'Position', [0.25 0.53 0.05 0.02],'backgroundcolor','k',...
        'Min',7,...
        'Max',70,...
        'Value',BehCtrl.Task.targetSF,...
        'enable','on','Callback', @slideTargetSF);
        set(BehCtrl.handles.slider_targetSF,'SliderStep',...
            [1/(BehCtrl.handles.slider_targetSF.Max - BehCtrl.handles.slider_targetSF.Min),1/(BehCtrl.handles.slider_targetSF.Max - BehCtrl.handles.slider_targetSF.Min)]);    
BehCtrl.handles.enter_targetSF = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.3 0.53 0.02 0.02],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.targetSF)),'Callback',@updateTargetSF);  
%(Dist)    
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.25 0.59 0.07 0.02],'Style','edit','Enable','inactive',...
    'String','Dist SF');    
BehCtrl.handles.slider_distSF = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
        'Position', [0.25 0.57 0.05 0.02],'backgroundcolor','k',...
        'Min',7,...
        'Max',70,...
        'Value',BehCtrl.Task.targetSF,...
        'enable','on','Callback', @slideDistSF);
        set(BehCtrl.handles.slider_distSF,'SliderStep',...
            [1/(BehCtrl.handles.slider_distSF.Max - BehCtrl.handles.slider_distSF.Min),1/(BehCtrl.handles.slider_distSF.Max - BehCtrl.handles.slider_distSF.Min)]);    
BehCtrl.handles.enter_distSF = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.3 0.57 0.02 0.02],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.distSF)),'Callback',@updateDistSF);     

%---- [ONLY FOR TRAINING] change target location every N trials (currently
%works only in 2 and 1 patch modes [0.4 0.34 0.07 0.03]
BehCtrl.handles.changeTargetLocation = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','popup',...
    'Position', [0.25 0.50 0.07 0.02],...
    'String',{'No Shift/Noise','Shift Target','Add Noise'},'enable','on','Callback', @changeTargetLocation,'FontWeight','bold');
BehCtrl.handles.resetNtrialsCounter = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton','BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.32 0.50 0.05 0.02],'Enable','on',...
    'String','Every N trials','Callback', @resetNtrialsCounter);      
BehCtrl.handles.changeTargetEveryNtrials = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.37 0.50 0.03 0.02],'Style','edit','enable','on',...
        'String',sprintf('%s',num2str(BehCtrl.Task.NumTrialsToChangeTarget)),'Callback',@changeNumTrialsToChangeTarget);  
BehCtrl.handles.remainingTrials = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.50 0.07 0.02],'Style','edit','Enable','inactive',...
        'String',sprintf('%s',num2str(BehCtrl.Task.NumTrialsToChangeTarget)));   
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.32 0.48 0.08 0.02],'Style','edit','Enable','inactive',...
    'String','Noise');      
BehCtrl.handles.noiseOnTarget = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.48 0.07 0.02],'Style','edit','enable','inactive',...
        'String',sprintf('%s',num2str(BehCtrl.Task.noiseOnTarget)),'Callback',@changeNoiseOnTarget);      
    
%---- set size of go and nogo stimuli (sine wave mode)   
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.33 0.55 0.07 0.02],'Style','edit','Enable','inactive',...
    'String','Target Size');    
BehCtrl.handles.slider_size = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
        'Position', [0.33 0.53 0.05 0.02],'backgroundcolor','k',...
        'Min',8,...
        'Max',100,...
        'Value',BehCtrl.Task.Size,...
        'enable','on','Callback', @slideSize);
        set(BehCtrl.handles.slider_size,'SliderStep',...
            [1/(BehCtrl.handles.slider_size.Max - BehCtrl.handles.slider_size.Min),1/(BehCtrl.handles.slider_size.Max - BehCtrl.handles.slider_size.Min)]);    
BehCtrl.handles.enterSize = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.38 0.53 0.02 0.02],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.Size)),'Callback',@updateSize); 
    
%---- set size of go and nogo stimuli (bar mode: defined by '1_patch_bar')   
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.41 0.55 0.07 0.02],'Style','edit','Enable','inactive',...
    'String','Target Size (bar)');      
BehCtrl.handles.slider_holeSize = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
        'Position', [0.41 0.53 0.05 0.02],'backgroundcolor','k',...
        'Min',1000,...
        'Max',6000,...
        'Value',BehCtrl.Bar.holeSize,...
        'enable','off','Callback', @slideHoleSize);
BehCtrl.handles.enterholeSize = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.46 0.53 0.02 0.02],'Style','edit','enable','off',...
        'String',sprintf('%s',num2str(BehCtrl.Bar.holeSize)),'Callback',@updateHoleSize);         
%---- set contrast of go and nogo stimuli    
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.48 0.79 0.04 0.02],'Style','edit','Enable','inactive',...
    'String','Contrast');      
BehCtrl.handles.contrast = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','listbox',...
    'Position', [0.48 0.69 0.04 0.1],...
    'max',4,'min',1,...
    'String',{'100','75','50','25','18.75','12.5','6.25'},... 
    'Callback', @updateContrast); 

%---- make distractor dimmer
BehCtrl.handles.removeDistractor = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.33 0.60 0.06 0.02],... % [0.41 0.6 0.04 0.02],...
    'String','remove Dist ?','BackgroundColor', [0,0.25,0],'ForegroundColor','white','enable','on','Callback', @removeDist,'FontWeight','bold');
%---- Shift target angle
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.42 0.67 0.07 0.02],'Style','edit','Enable','inactive',...
    'String','Shift Angle');    
BehCtrl.handles.shiftAngle = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
        'Position', [0.42 0.65 0.06 0.02],'backgroundcolor','k',...
        'Min',-30,...
        'Max',30,...
        'Value',BehCtrl.Task.shiftAngle,...
        'SliderStep',[1/60,1/60],...
        'enable','on','Callback', @slideShiftAngle);
BehCtrl.handles.disp_shiftAngle = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.48 0.65 0.01 0.02],'Style','edit','Enable','inactive',...
        'String',sprintf('%s',num2str(BehCtrl.Task.shiftAngle))); 




%---- distractor shown at non attention location at random timing
BehCtrl.handles.showITIdistractor = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.39 0.60 0.03 0.02],... % [0.41 0.6 0.04 0.02],...
    'String','ITI-Dist ?','BackgroundColor', [0,0.25,0],'ForegroundColor','white','enable','on','Callback', @showITIdistractor,'FontWeight','bold');
BehCtrl.handles.randomDistProb = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.39 0.58 0.03 0.02],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.randomDistProb)),'Callback',@changeRandomDistProb);

%---- ITI distractor also on the attended location
BehCtrl.handles.showITIdistractorOnAttended = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.42 0.62 0.06 0.02],... % [0.41 0.6 0.04 0.02],...
    'String','ITI-Dist-ON-Attended?','BackgroundColor', [0,0.25,0],'ForegroundColor','white','enable','on','Callback', @showITIdistractorOnAttended,'FontWeight','bold');
    
%---- duration (sec) of distructor stimulus during ITI
uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
    'Position',[0.42 0.60 0.06 0.02],'Style','edit','Enable','inactive',...
    'String','Dist.Duration');    
BehCtrl.handles.durationDist = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.42 0.58 0.06 0.02],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.durationDist)),'Callback',@changeDurationDist);
%---- no sparse noise when target shown button
BehCtrl.handles.showSNonTarget = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.33 0.58 0.06 0.02],... %[0.41 0.58 0.07 0.02],...
    'String','Show SN on Target?','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @showSNonTarget,'FontWeight','bold');
    
    % %- preset,Pre (5deg)
%     BehCtrl.handles.stimLocation.presetPre5 = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
%     'Position', [0.25 0.66 0.01875 0.03],...
%     'String','Pre_5','ForegroundColor','white','BackgroundColor', 'black','enable','on','Callback', @stimPreset_Pre_5deg,'FontWeight','bold');
% %- preset,Pre (10deg)
%     BehCtrl.handles.sBehCtrl.handles.enterholeSizetimLocation.presetPre10 = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
%     'Position', [0.26875 0.66 0.01875 0.03],...
%     'String','Pre_10','ForegroundColor','white','BackgroundColor', 'black','enable','on','Callback', @stimPreset_Pre_10deg,'FontWeight','bold');

% text
    %uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','text','Position',[0.35 0.45 0.10 0.05],'String','Stim Location','FontWeight','bold');


% Condition selection buttons
% give Auto Reward?
    BehCtrl.handles.ifGiveAR = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.5 0.40 0.125 0.03],...
    'String','Stop Auto Reward?','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @updateARSetting,'FontWeight','bold');
% puff on FA?
    BehCtrl.handles.ifPuffOnFA = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.5 0.37 0.125 0.03],...
    'String','Stop Puff on FA?','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @updatePuffSetting,'FontWeight','bold');
% reset after early lick?
    BehCtrl.handles.ifResetAfterEL = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.5 0.34 0.125 0.03],...
    'String','Stop Reseting on EL?','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @updateEarlyLickSetting,'FontWeight','bold');

% stop any valve opening?
    BehCtrl.handles.ifStopValveOpening = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.5 0.31 0.125 0.03],...
    'String','Stop LFR reward?','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @updateRewardSetting,'FontWeight','bold');

% running trigger Trials
    BehCtrl.handles.ifTriggerByRun = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.5 0.28 0.1 0.03],...
    'String','Running Trigger Trial?','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @runningTriggerTrials,'FontWeight','bold');
% running speed threshold
    BehCtrl.handles.RunSpeedThresh = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.60 0.28 0.025 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.SpeedThresh)),'Callback',@changeRunSpeedthreshold);
% timelimit of session
    BehCtrl.handles.sessionTimeLimit = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
        'Position',[0.5 0.25 0.1 0.03],...
        'String','Time Limit ON','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @sessionHAStimeLimit,'FontWeight','bold');
% session time
    BehCtrl.handles.sessionTimeValue = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.6 0.25 0.025 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.sessionTime)),'Callback',@changeSessionTimeValue);
% activate block structure?
    BehCtrl.handles.activateBlock = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','togglebutton',...
    'Position', [0.625 0.40 0.075 0.03],...
    'String','activate Block?','BackgroundColor', [1,0.4,0.15],'enable','on','Callback', @activateBlock,'FontWeight','bold');
% number of blocks
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.625 0.37 0.05 0.03],'Style','edit','Enable','inactive',...
        'String','num Blocks');
    BehCtrl.handles.numBlocks = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.672 0.37 0.025 0.03],'Style','edit','Enable','on',...
        'String',sprintf('%s',num2str(BehCtrl.Task.numBlocks)),'Callback',@changeNumBlocks);
% block size
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.625 0.34 0.05 0.03],'Style','edit','Enable','inactive',...
        'String','block size');
    BehCtrl.handles.blockSize = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.672 0.34 0.025 0.03],'Style','edit','Enable','on',...
        'String',sprintf('%s',num2str(BehCtrl.Task.blockSize)),'Callback',@changeBlockSize);
% block trial counter
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.625 0.31 0.05 0.03],'Style','edit','Enable','inactive',...
        'String','trial count');
    BehCtrl.handles.blockTrialCounter = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.672 0.31 0.025 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.blockTrialCount)));
% block counter
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.625 0.28 0.05 0.03],'Style','edit','Enable','inactive',...
        'String','Block count');
    BehCtrl.handles.blockCounter = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.672 0.28 0.025 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.blockCount)));

% valve duration
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.40 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','valve duration');
    BehCtrl.handles.ValveDuration = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.40 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.ValveDuration)),'Callback',@changeValveDuration);
% autoreward valve duration
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.37 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','auto reward valve duration');
    BehCtrl.handles.AutoRewValveDuration  = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.37 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.AutoRewValveDuration)),'Callback',@changeAutoRewValveDuration);
% air valve duration
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.34 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','Air valve duration');
    BehCtrl.handles.AirValveDuration = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.34 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.AirValveDuration)),'Callback',@changeAirValveDuration);
% valve opening delay (variable)    
    BehCtrl.handles.ifValveOpensWithDelay = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Style','togglebutton',...
        'Position', [0.25 0.30 0.06 0.04],...
        'String','w/o delay?','BackgroundColor', [0.4,0.4,0.5],'Callback', @giveDelayBeforeValveOpens);  
    % mean
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.31 0.32 0.04 0.02],'Style','edit','Enable','inactive',...
        'String','mu');  
    BehCtrl.handles.ValveDelay_mean = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.31 0.30 0.04 0.02],'Style','edit',...
        'enable','on',... % inactive by default
        'String',sprintf('%s',num2str(BehCtrl.Task.delayMean)),'Callback',@changeValveDelay_mean);
    % sd
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.35 0.32 0.04 0.02],'Style','edit','Enable','inactive',...
        'String','sd'); 
    BehCtrl.handles.ValveDelay_sd = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.35 0.30 0.04 0.02],'Style','edit',...
        'enable','on',... % inactive by default
        'String',sprintf('%s',num2str(BehCtrl.Task.delaySD)),'Callback',@changeValveDelay_sd);    
    % lower bound
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.39 0.32 0.04 0.02],'Style','edit','Enable','inactive',...
        'String','min');  
    BehCtrl.handles.ValveDelay_min = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.39 0.30 0.04 0.02],'Style','edit',...
        'enable','on',... % inactive by default
        'String',sprintf('%s',num2str(BehCtrl.Task.delayMin)),'Callback',@changeValveDelay_min);      
    % upper bound
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.43 0.32 0.04 0.02],'Style','edit','Enable','inactive',...
        'String','max');   
    BehCtrl.handles.ValveDelay_max = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.43 0.30 0.04 0.02],'Style','edit',...
        'enable','on',... % inactive by default
        'String',sprintf('%s',num2str(BehCtrl.Task.delayMax)),'Callback',@changeValveDelay_max);  
    
% Task stimulus duration
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.26 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','Stim duration');
    BehCtrl.handles.stimDuration = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.26 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.StimDuration)),'Callback',@changeStimDuration);
% autoreward delay
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.23 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','auto reward delay');
    BehCtrl.handles.AutoRewDelay = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.23 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.AutoRewDelay)),'Callback',@changeAutoRewDur);
% go stimulus probability
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.18 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','go stimulus probability');
    BehCtrl.handles.Goprob = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.18 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.Goprob)),'Callback',@changeGoprob);
    
% catch trial probability
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.14 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','CATCH probability');
    BehCtrl.handles.Catchprob = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.14 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.Catchprob)),'Callback',@changeCatchprob);   
    
% number of hit before catch trials start
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.11 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','num Hits before CATCH');
    BehCtrl.handles.numHitsBeforecatch = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.11 0.035 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.numHitsBeforecatch)),'Callback',@changeNumHitsBeforecatch);     
    BehCtrl.handles.hitCounterForCatch = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.435 0.11 0.035 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.hitCounterForCatch)));       
% lick threshold
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.07 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','lick detection threshold');
    BehCtrl.handles.LickThresh = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.07 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.LickThresh)),'Callback',@changelickthreshold);
% ITI duration    
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0.03 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','ITI duration');
    BehCtrl.handles.ITIduration = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0.03 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.ITIduration)),'Callback',@changeITIduration);
    
% Grace Period
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.25 0 0.15 0.03],'Style','edit','Enable','inactive',...
        'String','Grace period');
    BehCtrl.handles.GracePeriod = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.4 0 0.07 0.03],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.GracePeriod)),'Callback',@changeGracePeriod);
    
% if Naturalistic image...

   
%     BehCtrl.handles.PatchONgray = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','yellow','ForegroundColor','black','FontWeight','bold','Units','normalized',...
%         'Position',[0.6 0.37 0.07 0.05],'Style','togglebutton',...
%         'String','Shown!','Callback',@showPatchOnGray);   
% --- test Vizi
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.5 0.21 0.05 0.03],'Style','edit','Enable','inactive','String','B.G.');
        % each element for background stimulus
        BehCtrl.handles.BG1 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.55 0.21 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.BG1)));
        BehCtrl.handles.BG2 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.575 0.21 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.BG2)));    
        BehCtrl.handles.BG3 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.6 0.21 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.BG3)));    
        BehCtrl.handles.BG4 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.625 0.21 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.BG4)));    
        BehCtrl.handles.BG5 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.65 0.21 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.BG5)));    
        BehCtrl.handles.BG6 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.675 0.21 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.BG6))); 
    
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.5 0.18 0.05 0.03],'Style','edit','Enable','inactive','String','GratingL');    
        % each element for first grating stimulus
        BehCtrl.handles.GRone1 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.55 0.18 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRone1)));
        BehCtrl.handles.GRone2 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.575 0.18 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRone2)));    
        BehCtrl.handles.GRone3 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.6 0.18 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRone3)));    
        BehCtrl.handles.GRone4 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.625 0.18 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRone4)));    
        BehCtrl.handles.GRone5 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.65 0.18 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRone5)));    
        BehCtrl.handles.GRone6 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.675 0.18 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRone6)));   
    
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.5 0.15 0.05 0.03],'Style','edit','Enable','inactive','String','GratingR');  
        % each element for second grating stimulus
        BehCtrl.handles.GRtwo1 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.55 0.15 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRtwo1)));
        BehCtrl.handles.GRtwo2 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.575 0.15 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRtwo2)));    
        BehCtrl.handles.GRtwo3 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.6 0.15 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRtwo3)));    
        BehCtrl.handles.GRtwo4 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.625 0.15 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRtwo4)));    
        BehCtrl.handles.GRtwo5 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.65 0.15 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRtwo5)));    
        BehCtrl.handles.GRtwo6 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.675 0.15 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.GRtwo6))); 
    
    BehCtrl.handles.foreground = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold',...
        'Units','normalized',...
        'Position',[0.5 0.12 0.05 0.03],'Style','togglebutton','String','F.G','Callback',@edgeSharpOrGraded);   
        % each element for first patch for photodiode
        BehCtrl.handles.FG1 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.55 0.12 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.FG1)));
        BehCtrl.handles.FG2 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.575 0.12 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.FG2)));    
        BehCtrl.handles.FG3 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.6 0.12 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.FG3)));    
        BehCtrl.handles.FG4 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.625 0.12 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.FG4)));    
        BehCtrl.handles.FG5 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.65 0.12 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.FG5)));    
        BehCtrl.handles.FG6 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.675 0.12 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.FG6)));  
    
    BehCtrl.handles.photodiode = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold',...
        'Units','normalized',...
        'Position',[0.5 0.09 0.05 0.03],'Style','togglebutton','String','PD','Callback',@photodiodePatchOnOff);   
        % each element for first patch for photodiode
        BehCtrl.handles.PD1 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.55 0.09 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.PD1)));
        BehCtrl.handles.PD2 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.575 0.09 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.PD2)));    
        BehCtrl.handles.PD3 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.6 0.09 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.PD3)));    
        BehCtrl.handles.PD4 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.625 0.09 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.PD4)));    
        BehCtrl.handles.PD5 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.65 0.09 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.PD5)));    
        BehCtrl.handles.PD6 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.675 0.09 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.PD6)));
    
    BehCtrl.handles.LSN = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold',...
        'Units','normalized',...
        'Position',[0.5 0.06 0.05 0.03],'Style','edit','Enable','inactive','String','LSN');  
        % each element for second patch for photodiode
        BehCtrl.handles.LSN1 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.55 0.06 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.LSN1)));
        BehCtrl.handles.LSN2 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.9,1,0.95],'Units','normalized',...
        'Position',[0.575 0.06 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.LSN2)));    
        BehCtrl.handles.LSN3 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.9,1,0.95],'Units','normalized',...
        'Position',[0.6 0.06 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.LSN3)));    
        BehCtrl.handles.LSN4 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.625 0.06 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.LSN4)));    
        BehCtrl.handles.LSN5 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.65 0.06 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.LSN5)));    
        BehCtrl.handles.LSN6 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.675 0.06 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.LSN6))); 
    
    BehCtrl.handles.sinePatch = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold',...
        'Units','normalized',...
        'Position',[0.5 0.03 0.05 0.03],'Style','edit','Enable','inactive','String','Sine');  
        % each element for second patch for photodiode
        BehCtrl.handles.sinePatch1 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.55 0.03 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.sine1)));
        BehCtrl.handles.sinePatch2 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.575 0.03 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.sine2)));    
        BehCtrl.handles.sinePatch3 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.6 0.03 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.sine3)));    
        BehCtrl.handles.sinePatch4 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.625 0.03 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.sine4)));    
        BehCtrl.handles.sinePatch5 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.65 0.03 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.sine5)));    
        BehCtrl.handles.sinePatch6 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.675 0.03 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.sine6)));     
        BehCtrl.handles.sinePatch7 = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor','white','Units','normalized',...
        'Position',[0.70 0.03 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.sine7)));  
    
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold',...
        'Units','normalized',...
        'Position',[0.5 0 0.05 0.03],'Style','edit','Enable','inactive','String','(in pixel)'); % write the function!  
        % each element for second patch for photodiode
        BehCtrl.handles.pixelX = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.9,1,0.95],'Units','normalized',...
        'Position',[0.575 0 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.pixelX)),'Callback',@convertPxlToVizivalueX);    
        BehCtrl.handles.pixelY = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.9,1,0.95],'Units','normalized',...
        'Position',[0.6 0 0.025 0.03],'Style','edit','String',sprintf('%s',num2str(BehCtrl.Vizi.pixelY)),'Callback',@convertPxlToVizivalueY);    
     
    BehCtrl.handles.sendUpdateVizi = uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[1,0.4,0.15],'ForegroundColor','black',...
        'FontWeight','bold','Units','normalized',...
        'Position',[0.625 0 0.1 0.03],'Style','pushbutton',...
        'String','send & update Vizi','Callback',@sendAndSetViziVector);    
    
 
    
    
    
%%-------------------------------------------------------------------------
%%--------------Slider for adjusting target location
    BehCtrl.handles.manualAdjustTarget = ...
        axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.50 0.54 0.16 0.14],...
        'xticklabel',[],'yticklabel',[],...
        'XLimMode','manual','XLim',[-700 700],...
        'YLimMode','manual','YLim',[-680 680]);
    BehCtrl.patchMat = load('patchSettingFor_16_9.mat');
    BehCtrl.Vizi.usefulMat = ones(18,32);
        BehCtrl.Vizi.usefulMat(:,[1:BehCtrl.Vizi.useless_left,end-BehCtrl.Vizi.useless_right+1:end]) = 0;
        BehCtrl.Vizi.usefulMat([1:BehCtrl.Vizi.useless_top,end-BehCtrl.Vizi.useless_bottom+1:end],:) = 0;
    BehCtrl.Vizi.patchMat_x = BehCtrl.patchMat.patchMonitorMat_x .* BehCtrl.Vizi.usefulMat;
    BehCtrl.Vizi.patchMat_y = BehCtrl.patchMat.patchMonitorMat_y .* BehCtrl.Vizi.usefulMat;
    plot(BehCtrl.handles.manualAdjustTarget,BehCtrl.Vizi.patchMat_x(:),BehCtrl.Vizi.patchMat_y(:),...
        'b.','MarkerSize',.2);
    set(BehCtrl.handles.manualAdjustTarget,'XLimMode','manual','XLim',[-700 700],'YLimMode','manual','YLim',[-680 680],...
        'xticklabel',[],'yticklabel',[]);
    hold on
    % display default position of target
    plot(BehCtrl.Sine.position_one(1) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Sine.position_one(2) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_one);
    plot(BehCtrl.Sine.position_two(1) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Sine.position_two(2) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_two);    
    plot(BehCtrl.Sine.position_three(1) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Sine.position_three(2) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_three);    
    plot(BehCtrl.Vizi.grating1(2) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Vizi.grating1(3) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_bar);        
    % slider for target 1 (azimuth)
     BehCtrl.handles.slider_one_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.50 0.52 0.16 0.02],'backgroundcolor',BehCtrl.Sine.color_one,...
            'Max',BehCtrl.patchMat.patchMonitorMat_x(1,end-BehCtrl.Vizi.useless_right),...
            'Min',BehCtrl.patchMat.patchMonitorMat_x(1,BehCtrl.Vizi.useless_left+1),...
            'Value',BehCtrl.Sine.position_one(1),...
            'enable','on','Callback', @slide_one_azimuth);
        % set position by entering a value (target 1, azimuth)
        BehCtrl.handles.enter_one_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.66 0.52 0.025 0.02],'Style','edit',...
            'String',sprintf('%s',num2str(BehCtrl.Sine.position_one(1))),'Callback',@updateEnter_one_azimuth);  
    % slider for target 2 (azimuth)
     BehCtrl.handles.slider_two_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.50 0.50 0.16 0.02],'backgroundcolor',BehCtrl.Sine.color_two,...
            'Max',BehCtrl.patchMat.patchMonitorMat_x(1,end-BehCtrl.Vizi.useless_right),...
            'Min',BehCtrl.patchMat.patchMonitorMat_x(1,BehCtrl.Vizi.useless_left+1),...
            'Value',BehCtrl.Sine.position_two(1),...
            'enable','on','Callback', @slide_two_azimuth);
        % set position by entering a value (target 2, azimuth)
        BehCtrl.handles.enter_two_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.66 0.50 0.025 0.02],'Style','edit',...
            'String',sprintf('%s',num2str(BehCtrl.Sine.position_two(1))),'Callback',@updateEnter_two_azimuth); 
    % slider for target 3 (azimuth)
     BehCtrl.handles.slider_three_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.50 0.48 0.16 0.02],'backgroundcolor',BehCtrl.Sine.color_three,...
            'Max',BehCtrl.patchMat.patchMonitorMat_x(1,end-BehCtrl.Vizi.useless_right),...
            'Min',BehCtrl.patchMat.patchMonitorMat_x(1,BehCtrl.Vizi.useless_left+1),...
            'Value',BehCtrl.Sine.position_three(1),...
            'enable','off','Callback', @slide_three_azimuth);
        % set position by entering a value (target 3, azimuth)
        BehCtrl.handles.enter_three_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.66 0.48 0.025 0.02],'Style','edit','enable','off',...
            'String',sprintf('%s',num2str(BehCtrl.Sine.position_three(1))),'Callback',@updateEnter_three_azimuth);
    % slider for bar (azimuth)
     BehCtrl.handles.slider_bar_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.50 0.46 0.16 0.02],'backgroundcolor',BehCtrl.Sine.color_bar,...
            'Max',BehCtrl.patchMat.patchMonitorMat_x(1,end-BehCtrl.Vizi.useless_right),...
            'Min',BehCtrl.patchMat.patchMonitorMat_x(1,BehCtrl.Vizi.useless_left+1),...
            'Value',BehCtrl.Vizi.grating1(2),...
            'enable','off','Callback', @slide_bar_azimuth);
        % set position by entering a value (target 4, azimuth)
        BehCtrl.handles.enter_bar_azimuth = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.66 0.46 0.025 0.02],'Style','edit','enable','off',...
            'String',sprintf('%s',num2str(BehCtrl.Vizi.grating1(2))),'Callback',@updateEnter_bar_azimuth);    

        
    % slider for target 1 (altitude)
     BehCtrl.handles.slider_one_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.66 0.54 0.01 0.14],'backgroundcolor',BehCtrl.Sine.color_one,...     
            'Min',BehCtrl.patchMat.patchMonitorMat_y(end-BehCtrl.Vizi.useless_bottom,1),...
            'Max',BehCtrl.patchMat.patchMonitorMat_y(BehCtrl.Vizi.useless_top+1,1),...
            'Value',BehCtrl.Sine.position_one(2),...
            'enable','on','Callback', @slide_one_altitude);
        % set position by entering a value (Go, azimuth)
        BehCtrl.handles.enter_one_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.66 0.68 0.02 0.02],'Style','edit',...
            'String',sprintf('%s',num2str(BehCtrl.Sine.position_one(2))),'Callback',@updateEnter_one_altitude);      
    % slider for target 2 (altitude)
     BehCtrl.handles.slider_two_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.67 0.54 0.01 0.14],'backgroundcolor',BehCtrl.Sine.color_two,...
            'Min',BehCtrl.patchMat.patchMonitorMat_y(end-BehCtrl.Vizi.useless_bottom,1),...
            'Max',BehCtrl.patchMat.patchMonitorMat_y(BehCtrl.Vizi.useless_top+1,1),...
            'Value',BehCtrl.Sine.position_two(2),...
            'enable','on','Callback', @slide_two_altitude);
        % set position by entering a value (Go, azimuth)
        BehCtrl.handles.enter_two_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.67 0.70 0.02 0.02],'Style','edit',...
            'String',sprintf('%s',num2str(BehCtrl.Sine.position_two(2))),'Callback',@updateEnter_two_altitude);           
    % slider for target 3 (altitude)
     BehCtrl.handles.slider_three_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.68 0.54 0.01 0.14],'backgroundcolor',BehCtrl.Sine.color_three,...     
            'Min',BehCtrl.patchMat.patchMonitorMat_y(end-BehCtrl.Vizi.useless_bottom,1),...
            'Max',BehCtrl.patchMat.patchMonitorMat_y(BehCtrl.Vizi.useless_top+1,1),...
            'Value',BehCtrl.Sine.position_three(2),...
            'enable','off','Callback', @slide_three_altitude);
        % set position by entering a value (Go, azimuth)
        BehCtrl.handles.enter_three_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.68 0.68 0.02 0.02],'Style','edit','enable','off',...
            'String',sprintf('%s',num2str(BehCtrl.Sine.position_three(2))),'Callback',@updateEnter_three_altitude);      
    % slider for target 4 (altitude)
     BehCtrl.handles.slider_bar_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','slider',...
            'Position', [0.69 0.54 0.01 0.14],'backgroundcolor',BehCtrl.Sine.color_bar,...
            'Min',BehCtrl.patchMat.patchMonitorMat_y(end-BehCtrl.Vizi.useless_bottom,1),...
            'Max',BehCtrl.patchMat.patchMonitorMat_y(BehCtrl.Vizi.useless_top+1,1),...
            'Value',BehCtrl.Vizi.grating1(3),...
            'enable','off','Callback', @slide_bar_altitude);
        % set position by entering a value (Go, azimuth)
        BehCtrl.handles.enter_bar_altitude = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
            'Position',[0.69 0.70 0.02 0.02],'Style','edit','enable','off',...
            'String',sprintf('%s',num2str(BehCtrl.Vizi.grating1(3))),'Callback',@updateEnter_bar_altitude);
           
%%-------------------------------------------------------------------

%%--------------Plots

% Running Speed    
    BehCtrl.handles.axspeed = axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.75 0.9 0.25 0.06],'xticklabel',[]); %,...
       % 'YLimMode','manual','YLim',[0 150]);
    title('Speed - cm/s');
% Lick
    BehCtrl.handles.axlick=axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.75 0.78 0.25 0.06],'xticklabel',[]);
    title('Licks');
    
% code iteration/Galvo
    BehCtrl.handles.axGalvo = axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.75 0.68 0.25 0.05],'xticklabel',[],'YLimMode','manual');
    BehCtrl.handles.axGalvo.YAxis.LimitsMode = 'manual';
    BehCtrl.handles.axGalvo.YAxis.Limits = [0,10];
    BehCtrl.handles.axGalvo.Title.String = 'Galvo';
    % choose between galvo and iteration
    BehCtrl.handles.GalvoOrIteration = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
                                           'Position',[0.68 0.73 0.05 0.015],'Style','popup',...
                                           'String',{'Galvo','iteration'},'Callback',@switchGalvoOrIteration);      
% FA rate
    BehCtrl.handles.FA=axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.75 0.55 0.25 0.07],'xticklabel',[],'YLimMode','manual','YLim',[0 1]);
    BehCtrl.handles.FA.Title.String = 'FA'; 
% MS rate    
    BehCtrl.handles.MS=axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.75 0.4 0.25 0.07],'xticklabel',[],'YLimMode','manual','YLim',[0 1]);
    BehCtrl.handles.MS.Title.String = 'Miss';  
%%--------------Performance
    BehCtrl.handles.hits = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.75 0.33 0.08 0.04],...
        'String',sprintf('hits = %s',num2str(BehCtrl.Task.hits)),'FontWeight','bold','FontSize',8);   

    BehCtrl.handles.misses = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.75 0.29 0.08 0.04],...
        'String',sprintf('misses = %s',num2str(BehCtrl.Task.misses)),'FontWeight','bold','FontSize',8);

    BehCtrl.handles.falsealarms = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.75 0.25 0.08 0.04],...
        'String',sprintf('falsealarms = %s',num2str(BehCtrl.Task.falsealarms)),'FontWeight','bold','FontSize',8);
    
    BehCtrl.handles.trialnum = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.75 0.21 0.08 0.04],...
        'String',sprintf('numtrials = %s',num2str(BehCtrl.Task.trialNum)),'FontWeight','bold','FontSize',8);    
    
    BehCtrl.handles.hitOnCatch = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.75 0.17 0.08 0.04],...
        'String',sprintf('hit_catch = %s',num2str(BehCtrl.Task.hitOnCatch)),'FontWeight','bold','FontSize',8);  
    
    BehCtrl.handles.missOnCatch = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.75 0.13 0.08 0.04],...
        'String',sprintf('miss_catch = %s',num2str(BehCtrl.Task.missOnCatch)),'FontWeight','bold','FontSize',8);      
    

    
%%-------------------------------------------------------------------------
%%--------------Continuous Setting
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.84 0.33 0.14 0.04],'Style','edit','Enable','inactive',...
        'String','Force switch at N continuous trials');
    BehCtrl.handles.forceSwitchTrials  = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.98 0.33 0.02 0.04],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.forceSwitchTrials)),'Callback',@changeForceSwitchTrials);
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.84 0.25 0.14 0.04],'Style','edit','Enable','inactive',...
        'String','Avoid Go for N trials after the last');
    BehCtrl.handles.avoidGoTrials  = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.98 0.25 0.02 0.04],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.avoidGoTrials)),'Callback',@changeAvoidGoTrials);    
    uicontrol('Parent',BehCtrl.handles.f,'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white','FontWeight','bold','Units','normalized',...
        'Position',[0.84 0.17 0.14 0.04],'Style','edit','Enable','inactive',...
        'String','Bias Go probability after incorrect trials');
    BehCtrl.handles.bias  = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized',...
        'Position',[0.98 0.17 0.02 0.04],'Style','edit',...
        'String',sprintf('%s',num2str(BehCtrl.Task.bias)),'Callback',@changeBias);     
%%-------------------------------------------------------------------------
%%--------------Start & Stop 
    BehCtrl.handles.start = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.75 0 0.09 0.075],...
        'String','Start B.G.','BackgroundColor', 'green','enable','on','Callback', @start_backgroundRecording,'FontWeight','bold');
    BehCtrl.handles.start2 = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.84 0 0.09 0.075],...
        'String','Start task','BackgroundColor', 'green','enable','on','Callback', @start_task,'FontWeight','bold');
    BehCtrl.handles.stop = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.93 0 0.07 0.075],...
        'String','Stop','BackgroundColor', 'red','enable','off','Callback', @my_stopfcn,'FontWeight','bold');

%%-------------------------------------------------------------------------
%%--------------Monitor setting
    BehCtrl.handles.monitor1 = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.75 0.075 0.083 0.05],...
        'String','1920 x 1200','BackgroundColor', [0.4,0.4,0.5],'ForegroundColor','white','enable','on','Callback', @setMonitor1,'FontWeight','bold');
    BehCtrl.handles.monitor2 = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.833 0.075 0.083 0.05],...
        'String','mesoscope','BackgroundColor', [0.4,0.4,0.5],'ForegroundColor','white','enable','on','Callback', @setMonitor2,'FontWeight','bold');
    BehCtrl.handles.monitor3 = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.916 0.075 0.084 0.05],...
        'String','box','BackgroundColor', [0.4,0.4,0.5],'ForegroundColor','white','enable','on','Callback', @setMonitor3,'FontWeight','bold');    

%%-------------------------------------------------------------------------
%--------------initialization
disp('initializing everything...')
initialize_everything
disp('Done!')
% start_backgroundRecording
% start_task
end

% -------------------------------------------------------------------------------------------------------------------------------
% ----------------------------------------------------------------Subfunctions---------------------------------------------------


%% ----- important functions 
function initialize_everything
    global BehCtrl
        %---- adjust size
    BehCtrl.handles.f.Position = [0,0.04,0.95,0.88];
%     %---- make the monitor gray
    pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Vizi.GrayWithoutPDString);
    pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
    
    %---- time counting for the whole session
    BehCtrl.Session.tic = tic;
    %---- open a ni session and set up counter
    BehCtrl.sess = daq.createSession('ni');
    BehCtrl.Digsess = daq.createSession('ni');% reward valve and puff valve
    BehCtrl.Digsess2 = daq.createSession('ni');% target stimuli onset/offset
    
    % daq channel settings
    switch BehCtrl.experimentMode
        case 1 % box mode
            addCounterInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ctr0','Position'); % X1 coding, alright?
            BehCtrl.AIchannel.Lick = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai0','Voltage');   % lick spout            
            BehCtrl.AIchannel.VisOnset = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai8','Voltage');    % target onset/offset
            BehCtrl.AIchannel.Valve =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai12','Voltage');   % valve
            %BehCtrl.AIchannel.Puff =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai9','Voltage');    % puff

            BehCtrl.AIchannel.Lick.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.VisOnset.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.Valve.TerminalConfig = 'SingleEnded';
            %BehCtrl.AIchannel.Puff.TerminalConfig = 'SingleEnded';
         
            addDigitalChannel(BehCtrl.Digsess,BehCtrl.DevNum,{'port0/line1','port0/line6'},'OutputOnly');%'port0/line1' is reward valve, 'port0/line6' is air puff
            addDigitalChannel(BehCtrl.Digsess2,BehCtrl.DevNum,'port0/line5','OutputOnly'); 
        case 2 % macbook
            addCounterInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ctr0','Position'); % X1 coding, alright?
            BehCtrl.AIchannel.Lick = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai10','Voltage');   % lick spout
            BehCtrl.AIchannel.Photodiode =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai6','Voltage');    % Photodiode (only for imaging setup)
            BehCtrl.AIchannel.galvo =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai2','Voltage');   % galvo      (only for imaging setup)
            BehCtrl.AIchannel.VisOnset = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai1','Voltage');    % target onset/offset
            BehCtrl.AIchannel.Valve =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai4','Voltage');   % valve
            BehCtrl.AIchannel.Puff =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai3','Voltage');    % puff
            BehCtrl.AIchannel.TeensySpeed = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai9','Voltage');    % Running speed from Teensy
            
            BehCtrl.AIchannel.Lick.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.VisOnset.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.Photodiode.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.Valve.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.Puff.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.galvo.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.TeensySpeed.TerminalConfig = 'SingleEnded';
            
            addDigitalChannel(BehCtrl.Digsess,BehCtrl.DevNum,{'port0/line0','port0/line6'},'OutputOnly');%'port0/line1' is reward valve, 'port0/line6' is air puff
            addDigitalChannel(BehCtrl.Digsess2,BehCtrl.DevNum,'port0/line4','OutputOnly');
        case 3 % 2pRAM
            addCounterInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ctr0','Position'); % X1 coding, alright?
            BehCtrl.AIchannel.Lick = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai0','Voltage');   % lick spout
            BehCtrl.AIchannel.Photodiode =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai6','Voltage');    % Photodiode (only for imaging setup)
            BehCtrl.AIchannel.galvo =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai2','Voltage');   % galvo      (only for imaging setup)
            BehCtrl.AIchannel.VisOnset = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai1','Voltage');    % target onset/offset
            BehCtrl.AIchannel.Valve =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai4','Voltage');   % valve
            BehCtrl.AIchannel.Puff =addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai3','Voltage');    % puff
            BehCtrl.AIchannel.TeensySpeed = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai9','Voltage');    % Running speed from Teensy
            
            BehCtrl.AIchannel.Lick.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.VisOnset.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.Photodiode.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.Valve.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.Puff.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.galvo.TerminalConfig = 'SingleEnded';
            BehCtrl.AIchannel.TeensySpeed.TerminalConfig = 'SingleEnded';
            
            addDigitalChannel(BehCtrl.Digsess,BehCtrl.DevNum,{'port0/line0','port0/line6'},'OutputOnly');%'port0/line1' is reward valve, 'port0/line6' is air puff
            addDigitalChannel(BehCtrl.Digsess2,BehCtrl.DevNum,'port0/line4','OutputOnly');
    end

    %---- listening to ni input and generating output
    
    BehCtrl.sess.IsContinuous = 1;
    BehCtrl.sess.IsNotifyWhenScansQueuedBelowAuto = false;
%      BehCtrl.sess.NotifyWhenScansQueuedBelow = BehCtrl.sess.NotifyWhenDataAvailableExceeds;
    BehCtrl.lh = addlistener(BehCtrl.sess,'DataAvailable',@updateplots);

%     queueOutputData(BehCtrl.sess,[zeros(2,1000),repmat(3.99,[2,1])]');
%     BehCtrl.lh2 = addlistener(BehCtrl.sess,'DataRequired',@(src,event)disp('DATAREQUIRED')); % this is never gonna be executed. Could be implemented better

    %---- listeners to state
    BehCtrl.l1 = addlistener(BehCtrl.CurrState,'InterTrialInterval',@StartITI);
    BehCtrl.l2 = addlistener(BehCtrl.CurrState,'TrialStart',@SendTaskStim);
    BehCtrl.l3 = addlistener(BehCtrl.CurrState,'RewZone',@RewardZone);
    BehCtrl.l4 = addlistener(BehCtrl.CurrState,'PuffZone',@PuffZone);         
    BehCtrl.l5 = addlistener(BehCtrl.CurrState,'TrialEnd',@RestartTrial);
    BehCtrl.l6 = addlistener(BehCtrl.CurrState,'MouseLicked',@lickIndicatorColor);% this is a listener for lick indicator
    
    
    %---- define timer
    % stimuli cycles
    BehCtrl.tRFMap = timer('StartFcn',@(src,event)disp('tRFMap started!'),'TimerFcn',@sendAndUpdateRFStim,'BusyMode','error','ExecutionMode','fixedRate','StopFcn',@(src,event)disp('tRFMap stop func'));
        BehCtrl.tRFMap.Period = BehCtrl.RF.OneCycleDuration;
    % to record visual stimulus onset by sending digital output to analog input channel  (This timer is used only for rough RF mapping)(but this digital output is used for defining target stimli)  
    BehCtrl.tDigsessVisOnset = timer('StartFcn',@(src,event)outputSingleScan(BehCtrl.Digsess2,[1]),...
        'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess2,[0]),'BusyMode','error','TasksToExecute',1,'StartDelay',0.1);   
        
    BehCtrl.tTaskStim = timer('TimerFcn',@sendAndUpdateTaskStim,'BusyMode','error','ExecutionMode','fixedRate','StopFcn',@(src,event)disp('tTaskStim stop func'));
        BehCtrl.tTaskStim.Period = BehCtrl.RF.OneCycleDuration; % keep the rate same as that of RF mapping
    BehCtrl.tlicklistener_Rew = timer('TimerFcn',@addLicklistenerForReward,'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('Licklistener_rew started'));
        BehCtrl.tlicklistener_Rew.StartDelay = BehCtrl.Task.GracePeriod;    
    BehCtrl.tlicklistener_Puff = timer('TimerFcn',@addLicklistenerForPuff,'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('Licklistener_puff started'));
        BehCtrl.tlicklistener_Puff.StartDelay = BehCtrl.Task.GracePeriod;          
        
    BehCtrl.tITIcountDown = timer('StartFcn',@(src,event)disp('ITI count down started'),'TimerFcn',@(src,event)triggerITI(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1);
        BehCtrl.tITIcountDown.StartDelay = BehCtrl.Task.StimDuration;
        
    BehCtrl.tStartITI = timer('StartFcn',@(src,event)disp('tStartITI started!'),'TimerFcn',@sendITIGray,'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tStartITI stop func'));
        %BehCtrl.tStartITI.StartDelay = BehCtrl.RF.OneCycleDuration;
    BehCtrl.tDontStartITI = timer('StartFcn',@(src,event)disp('ITI skipped!'),'TimerFcn',@dontSendITIGray,'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tStartITI stop func'));
        BehCtrl.tDontStartITI.StartDelay = BehCtrl.RF.OneCycleDuration;% same timing as the one when Gray with patches starts    
    BehCtrl.tLoopITI = timer('StartFcn',@(src,event)disp('tLoopITI started!'),'TimerFcn',@loopITIGray,'BusyMode','error','ExecutionMode','fixedRate','Period',1,'StopFcn',@(src,event)disp('tLoopITI stop func'));
    %BehCtrl.tRew=timer('TimerFcn',@(src,event)triggerRewZone(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('trew stop func'));
    %BehCtrl.tPuff=timer('TimerFcn',@(src,event)triggerPuffZone(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tpuff stop func'));
    BehCtrl.tEnd=timer('TimerFcn',@(src,event)triggerTrialEnd(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tend stop func'));
        BehCtrl.tEnd.StartDelay = BehCtrl.Task.ITIduration;
    BehCtrl.tAux=timer('TimerFcn',@StartTimers,'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('taux stop func'),'StartDelay',0);

    BehCtrl.tNewTrialIndc=timer('TimerFcn',@(src,event)set(BehCtrl.handles.NewTrial, 'BackgroundColor','black'),'BusyMode','error','TasksToExecute',1,...
        'StartFcn',@(src,event)set(BehCtrl.handles.NewTrial, 'BackgroundColor','yellow'),'StartDelay',.3);
    
    BehCtrl.tValveClose=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','yellow'),...
        'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0]),'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.ValveDuration,...
        'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));
    BehCtrl.tOpenAirPuffValve=timer('TimerFcn',@openAndclosePuffValve,'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.ValveDelay);    
    BehCtrl.tOpenRewardValve=timer('TimerFcn',@openAndcloseRewardValve,'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.ValveDelay);
    BehCtrl.tAirValveClose=timer('StartFcn',@(src,event)set(BehCtrl.handles.Puff, 'BackgroundColor','yellow'),...
        'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0]),'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.AirValveDuration,...
        'StopFcn',@tAirValveCloseStopFcn);
%     BehCtrl.tValveCloseAutoRew=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','white'),...
%         'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0,0]),'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.AutoRewValveDuration,...
%         'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));
    BehCtrl.tValveCloseAutoRew=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','white'),...
        'TimerFcn',@closeAutoRew,'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.AutoRewValveDuration,...
        'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));
    BehCtrl.tValveCloseAutoRewOnceMore=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','white'),...
        'TimerFcn',@closeAutoRew,'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.AutoRewValveDuration,...
        'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));
    
    BehCtrl.tAutoRew=timer('TimerFcn',@OpenValveRewardAutoRew,'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.Task.AutoRewDelay + BehCtrl.Task.GracePeriod ,'StopFcn',@(src,event)disp('tautorew stop func'));
    BehCtrl.tTaskCounter = timer('TimerFcn',@updateTaskCounter,'BusyMode','error','ExecutionMode','fixedRate','StopFcn',@(src,event)disp('tTaskCounter stop func'));
        BehCtrl.tTaskCounter.Period = 1;    
        
    BehCtrl.tLickIndicatorColor = timer('StartFcn',@(~,~)set(BehCtrl.handles.lickIndicator,'BackgroundColor','green'),...
                                        'TimerFcn',@LickIndicatorColorBackToDark,...
                                        'StartDelay',0.2,...
                                        'BusyMode','error','TasksToExecute',1);  
    BehCtrl.tRoughRFMap = timer('TimerFcn',@sendAndUpdateRoughRFMap,'BusyMode','error','ExecutionMode','fixedRate','Period',4,...
                           'StartDelay',0);
          BehCtrl.tRoughRFMap.TasksToExecute = 4*BehCtrl.RoughMap.NumRepeat; 
    BehCtrl.tRoughFirst = timer('TimerFcn',@roughMap1st,'BusyMode','error');
          BehCtrl.tRoughFirst.StartDelay = 0;             
    BehCtrl.tRoughSecond = timer('TimerFcn',@roughMap2nd,'BusyMode','error');
          BehCtrl.tRoughSecond.StartDelay = 0.25;                       
    BehCtrl.tRoughFinish= timer('TimerFcn',@roughMapFinish,'BusyMode','error');
          BehCtrl.tRoughFinish.StartDelay = 0.5; 
          
    BehCtrl.tClearManualStimuli = timer('TimerFcn',@clearManualStimuli,'BusyMode','error');
          BehCtrl.tClearManualStimuli.StartDelay = 2; 
    %---- start time counter and start updating it
    BehCtrl.timerFirst.tic = tic;
    BehCtrl.timerSecond.tic = tic;
    BehCtrl.tTimerFirst = timer('TimerFcn',@updateTimerFirst,'BusyMode','error','ExecutionMode','fixedRate','StopFcn',@(src,event)disp('tTimerFirst stop func'));
        BehCtrl.tTimerFirst.Period = 1;
    BehCtrl.tTimerSecond = timer('TimerFcn',@updateTimerSecond,'BusyMode','error','ExecutionMode','fixedRate','StopFcn',@(src,event)disp('tTimerSecond stop func'));
        BehCtrl.tTimerSecond.Period = 1;
    start(BehCtrl.tTimerFirst);
    start(BehCtrl.tTimerSecond);
    
    %---- load one matrix of LSN order vector (load 5 deg by default)
    BehCtrl.RF.fileNumber = randsample(10,1);
    set(BehCtrl.handles.fileNumber,'String',num2str(BehCtrl.RF.fileNumber));
    BehCtrl.LSNStimMat = BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(:,:,BehCtrl.RF.fileNumber);
    BehCtrl.Vizi.targetWOsparsenoise = BehCtrl.LSNStimMat(1,:);
    BehCtrl.Vizi.targetWOsparsenoise(36:6:156) = 12;% send sparse noise background
    BehCtrl.orderInSession = BehCtrl.LSNvectorLibrary.orderInSession(BehCtrl.RF.fileNumber,:);
    
    BehCtrl.photodiode = BehCtrl.LSNStimMat(1,32);   
    
    
    %---- monitor setting
    switch BehCtrl.experimentMode
    case 1 % box training mode
        setMonitor3;
    case 2 % macbook
        setMonitor2;
    case 3 % 2pRAM
        setMonitor2;
    end
    
    
    
     % for mesoscope
    
    BehCtrl.initializeDone = 1;
end
    function start_backgroundRecording(src,event)
    global BehCtrl
    % clear unnecessary matrix from memory
    BehCtrl.LSNvectorLibrary.AllvectorsToBeSent = [];
    BehCtrl.LSNvectorLibrary.orderInSession = [];
    
    if BehCtrl.GalvoOrIteration == 2
        tic; % for iteration plot
    end
    %---- reset the first timer
    clearTimerFirst
    %---- update ui
    set(BehCtrl.handles.start, 'enable','off','String','B.G. undergoing...','BackgroundColor','yellow')
    set(BehCtrl.handles.stop, 'enable','on')
    cla(BehCtrl.handles.axspeed)
    drawnow;
    
    BehCtrl.Task.backgroundStarted = 1;

    BehCtrl.sess.startBackground()
    disp('blablabla')
    uiwait()     % Ask Mitra: Probably this stop blocking execution of the following lines when the source object (start button in this case) is deleted, which means when the window is closed?
    delete(BehCtrl.lh)
%     delete(BehCtrl.lh2)
    delete(BehCtrl.l1)
    delete(BehCtrl.l2)
    delete(BehCtrl.l3)
    delete(BehCtrl.l4)
    delete(BehCtrl.l5)
    delete(BehCtrl.l6)    
    if  isfield(BehCtrl,'licklistener_Rew')
    delete(BehCtrl.licklistener_Rew)
    end
    if  isfield(BehCtrl,'licklistener_AutoRew')
    delete(BehCtrl.licklistener_AutoRew)
    end    
    if  isfield(BehCtrl,'licklistener_Puff')
    delete(BehCtrl.licklistener_Puff)
    end
    if isfield(BehCtrl,'licklistener_earlyLick')
        delete(BehCtrl.licklistener_earlyLick)
    end
    %delete(BehCtrl.tRew)
    delete(BehCtrl.tEnd)
    delete(BehCtrl.tAux)
    delete(BehCtrl.tNewTrialIndc)
    delete(BehCtrl.tValveClose)
    delete(BehCtrl.tValveCloseAutoRew)
    delete(BehCtrl.tAutoRew)

    end
    
    function start_task(src,event)
    global BehCtrl
    BehCtrl.Task.started = true;
    %---- reset the second timer
    clearTimerSecond
    set(BehCtrl.handles.clearTimerSecond,'enable','off'); % to avoid pressing clear button, which will reset timer for TIME LIMIT
    if BehCtrl.Task.backgroundStarted == 1
    % update gui    
    set(BehCtrl.handles.start2, 'enable','off','String','Task undergoing...','BackgroundColor','yellow')
    % keep the original angle
    BehCtrl.Task.angleGo_original = BehCtrl.Task.angleGo;
    BehCtrl.Task.angleNogo_original = BehCtrl.Task.angleNogo;
    BehCtrl.Task.angleDist_original = BehCtrl.Task.angleDist;
    %----- start first trial
    BehCtrl.Task.tic = tic;
    triggerTrialStart(BehCtrl.CurrState);
    %-----
    start(BehCtrl.tTaskCounter);
    else
        disp('!!Start background recording first!!')
    end
    end
function updateplots(src,event)
global BehCtrl
BehCtrl.lickcont = event.Data(:,2);
BehCtrl.lick = (sign(BehCtrl.lickcont - BehCtrl.Task.LickThresh)+1)/2;

% save data
if BehCtrl.Save.AI >=0
    fwrite(BehCtrl.Save.AI,[event.TimeStamps(1:end),...
                            event.Data(:,1),...           % encoder ticks
                            BehCtrl.lick,...
                            event.Data(:,3:4),...         % photodiode, galvo                        
                            event.Data(:,5:7)>4,...       % target onset/offset, valve, puff; threshold is 4V instead of 5V
                            event.Data(:,8)]','single');  % running speed from Teensy
end
if sum(BehCtrl.lick) > 0
    triggerMouseLicked(BehCtrl.CurrState)
end
% % send position info to output
% queueOutputData(BehCtrl.sess,[mod(event.Data(:,1)* 0.0605,4) , BehCtrl.lick]) % in cms, mod 4?
%

% plot speed
BehCtrl.speed = ((event.Data((BehCtrl.precision_ms+1):1:end,1) - event.Data(1:1:(end-BehCtrl.precision_ms),1)) * 0.0605)/... % this should be 0.0785 if 40000 ticks per evolution and wheel diameter is 10 cm.
    (BehCtrl.precision_ms/BehCtrl.sess.Rate); % speed calc is bad, also better to divide by the difference between the actual timestamps
plot(BehCtrl.handles.axspeed,BehCtrl.speed);
set(BehCtrl.handles.axspeed,'YLimMode','manual','Ylim',[0 100])
% plot lick
plot(BehCtrl.handles.axlick,[BehCtrl.lickcont,BehCtrl.lick]);
% % plot galvo
if BehCtrl.GalvoOrIteration == 1
    BehCtrl.galvo = event.Data((BehCtrl.precision_ms+1):1:end,4);
    plot(BehCtrl.handles.axGalvo,BehCtrl.galvo);
    % set(BehCtrl.handles.axGalvo,'YLimMode','manual','Ylim',[0 10])
    % BehCtrl.handles.axGalvo.Title.String = 'Galvo';
    % drawnow;
elseif BehCtrl.GalvoOrIteration == 2
    % % check code iteration
    BehCtrl.toc = [toc,BehCtrl.toc];
    if length(BehCtrl.toc)>200
        BehCtrl.toc(end)=[];
    else
        BehCtrl.plots.iteration = plot(BehCtrl.handles.axGalvo,BehCtrl.toc);
    end
    BehCtrl.plots.iteration.YData = BehCtrl.toc;
    tic
end
% ----
drawnow limitrate 

if ~BehCtrl.timeIsOver
disp('updating plots')
end
end 
function startWOtarget(src,event)
global BehCtrl
% set the time limit to 45 min
BehCtrl.Task.sessionTime = 45;
set(BehCtrl.handles.sessionTimeValue,'String',sprintf('%s',num2str(BehCtrl.Task.sessionTime)));
BehCtrl.Task.woTarget = 1;
% make the size of target patches zero (hole size is set to be zero)
BehCtrl.LSNStimMat(:,26) = 0;
% make the size of gratings zero
BehCtrl.LSNStimMat(:,14) = 0;
BehCtrl.LSNStimMat(:,20) = 0;

% do the same for NAT

% lick doesn't trigger valve opening
BehCtrl.Task.LickThresh = 500;
% stop giving AR
BehCtrl.Task.AutoRew = false;
% ITI duration infinate
BehCtrl.Task.grayDuration.Min = 90000;
BehCtrl.Task.grayDuration.Mean = 90000;
BehCtrl.Task.grayDuration.Max = 90000;
% start the task
start_task()
end
%--------------------------------------------------------------------------
%% ----- visual stimulation
%----- Stim selection: RF mapping
function sendAndUpdateRFStim(src,event) % TimerFcn of tRFMap
global BehCtrl
% stop giving ITI distractor 2 sec before target onset
if BehCtrl.Task.showITIdistractor == true && BehCtrl.RF.iterationNum == BehCtrl.RF.Limit - round(2/BehCtrl.RF.OneCycleDuration)
    BehCtrl.Task.temporaryBlockDistr = true;
end
% when the number of iteration reaches the limit, RewZone/PuffZone is
% triggered
if BehCtrl.RF.iterationNum == BehCtrl.RF.Limit 
    %disp(strcat('trialID =',num2str(BehCtrl.Task.trialID)))
    stop(BehCtrl.tRFMap)
 
%---- notify either Go or NoGo
    switch BehCtrl.Task.trialID 
        case 2
        triggerRewZone(BehCtrl.CurrState)
        case 3 
        triggerPuffZone(BehCtrl.CurrState) 
        case 5 % catch trials
        triggerRewZone(BehCtrl.CurrState)    
    end
    start(BehCtrl.tITIcountDown)
else
%---- send a predefined ezvz vector
    convertAndsendVizivector(BehCtrl.Vizi.RFmapVectorToBeSent);


%---- send a digital line (if ITI is 0)    
    if BehCtrl.Task.TargetFlag == 1 % for defining the offset of target stimuli(if gray screen is not sent for ITI, the first RF stim is used for detect target offset)
    outputSingleScan(BehCtrl.Digsess2,[0])
    BehCtrl.Task.TargetFlag = 0;
    end

    % save info
    BehCtrl.RF.toc = toc(BehCtrl.Session.tic);
    if BehCtrl.save.startSaving == 1
        fprintf(BehCtrl.Save.fileID,'%8d %8d %8d %8d %8d %8d %8d %8.4f %8d %8d %8d %8d %8d\r\n',...
            BehCtrl.Task.trialNum,...
            BehCtrl.Task.trialID,...
            NaN,...
            NaN,...
            BehCtrl.RF.Total,...
            BehCtrl.RF.StimID,...
            0,...         % 1 is given when target stimuli are shown
            BehCtrl.RF.toc,...
            BehCtrl.Task.countCycleDist,...
            BehCtrl.Task.distID_ITI,...
            BehCtrl.Task.blockCount,...
            NaN,...
            BehCtrl.Task.ITIdistSide);        
    end
    
    % update gui first
    set(BehCtrl.handles.RFTotal,'String',sprintf('Total = %s',num2str(BehCtrl.RF.Total)));
    set(BehCtrl.handles.StimID,'String',sprintf('%s',num2str(BehCtrl.RF.StimID)));
    
    % then, set trial number to the one for the next trial
    BehCtrl.RF.Total = BehCtrl.RF.Total + 1;
    
    
    % same update to stimID
    if numel(BehCtrl.orderInSession) >= BehCtrl.RF.Total
        BehCtrl.RF.StimID = BehCtrl.orderInSession(BehCtrl.RF.Total);
    else
        BehCtrl.RF.StimID = BehCtrl.orderInSession(BehCtrl.RF.Total - numel(BehCtrl.orderInSession));
    end

    
    %---- define Vizi vector for the next
    if BehCtrl.RF.Mapping
        % Create a Vizi vector for the next here
          if  BehCtrl.Task.sessionHAStimeLimit % this should be true by default
            if BehCtrl.RF.Total > size(BehCtrl.LSNStimMat,1)
                % stop the program
                disp('task stopped since all stimli are used')
                taskStopfcn;
            elseif BehCtrl.timeIsOver
                % stop the program
                disp('task stopped since it reached time limit')
                taskStopfcn;                    
            else
                BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.LSNStimMat(BehCtrl.RF.Total,:);
            end
          else
            if BehCtrl.RF.Total > size(BehCtrl.LSNStimMat,1) || BehCtrl.timeIsOver
                BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.LSNStimMat(mod(BehCtrl.RF.Total,size(BehCtrl.LSNStimMat,1)),:);
            else
                BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.LSNStimMat(BehCtrl.RF.Total,:);
            end
          end


        % photodiode patch
        if BehCtrl.RF.CurrentPhotodiode == 3
           BehCtrl.Vizi.RFmapVectorToBeSent(27) = 1; % black photodiode patch
           BehCtrl.RF.CurrentPhotodiode = 1;
        elseif BehCtrl.RF.CurrentPhotodiode == 1
           BehCtrl.Vizi.RFmapVectorToBeSent(27) = 3; % white photodiode patch
           BehCtrl.RF.CurrentPhotodiode = 3;
        end  

    else
        BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.Vizi.GrayWithoutPD; 
    end
    % show distructor at non-attention location at some interval (this
    % currently works only 1) without RF mapping, 2) with relatively long
    % "One cycle duration", and 3) during ITI but not overlapping with
    % target stimulus (this should be enough for training purpose)
    if BehCtrl.Task.showITIdistractor == true && BehCtrl.Task.temporaryBlockDistr == false
        if BehCtrl.Task.countCycleDist == 0
            if rand < BehCtrl.Task.randomDistProb
                BehCtrl.Task.countCycleDist = BehCtrl.Task.countCycleDist + 1;
                BehCtrl.Task.distID_ITI = BehCtrl.Task.distID_candidate(randi(numel(BehCtrl.Task.distID_candidate)));
                % determine which location to show ITI distractor
                if BehCtrl.Task.ITIdistONattended == true
                    if rand < 0.5
                        BehCtrl.Task.ITIdistSide = 1;% show ITI distractor only on non-attended side
                    else
                        BehCtrl.Task.ITIdistSide = 2;% show ITI distractor only on Attended side
                    end
                else
                    BehCtrl.Task.ITIdistSide = 1;% show ITI distractor only on non-attended side
                end
            end
        end
        if BehCtrl.Task.countCycleDist > 0 && BehCtrl.Task.countCycleDist < BehCtrl.Task.numCycleDist + 1
            BehCtrl.Task.countCycleDist = BehCtrl.Task.countCycleDist + 1;% this is why this number is 2 on the first iteration of distractor (check the saved data)
            switch BehCtrl.Task.ITIdistSide
                case 1
                      switch BehCtrl.Task.distLocations(randi(length(BehCtrl.Task.distLocations),1))
                          case 1
                              if BehCtrl.RF.Mapping
                              BehCtrl.Vizi.RFmapVectorToBeSent(159:165) = [BehCtrl.Task.distID_ITI,...
                                                      BehCtrl.Vizi.sine_one(2),...
                                                      BehCtrl.Vizi.sine_one(3),...
                                                      5,...
                                                      BehCtrl.Vizi.sine_one(5),...
                                                      BehCtrl.Vizi.sine_one(6),...
                                                      BehCtrl.Vizi.sine_one(7)];  

                              BehCtrl.Vizi.RFmapVectorToBeSent = sendItBack(BehCtrl.Vizi.RFmapVectorToBeSent,BehCtrl.Sine.position_one); 
                              if BehCtrl.RF.degMode == 10
                                 BehCtrl.Vizi.RFmapVectorToBeSent = sendNeighborsBack(BehCtrl.Vizi.RFmapVectorToBeSent);
                              end                                

                              else
                              BehCtrl.Vizi.RFmapVectorToBeSent(159:165) = [BehCtrl.Task.distID_ITI,...
                                                      BehCtrl.Vizi.sine_one(2),...
                                                      BehCtrl.Vizi.sine_one(3),...
                                                      1,...
                                                      BehCtrl.Vizi.sine_one(5),...
                                                      BehCtrl.Vizi.sine_one(6),...
                                                      BehCtrl.Vizi.sine_one(7)];                   
                              end
                          case 2
                              if BehCtrl.RF.Mapping
                              BehCtrl.Vizi.RFmapVectorToBeSent(159:165) = [BehCtrl.Task.distID_ITI,...
                                                      BehCtrl.Vizi.sine_two(2),...
                                                      BehCtrl.Vizi.sine_two(3),...
                                                      5,...
                                                      BehCtrl.Vizi.sine_two(5),...
                                                      BehCtrl.Vizi.sine_two(6),...
                                                      BehCtrl.Vizi.sine_two(7)];  

                              BehCtrl.Vizi.RFmapVectorToBeSent = sendItBack(BehCtrl.Vizi.RFmapVectorToBeSent,BehCtrl.Sine.position_two); 
                              if BehCtrl.RF.degMode == 10
                                 BehCtrl.Vizi.RFmapVectorToBeSent = sendNeighborsBack(BehCtrl.Vizi.RFmapVectorToBeSent);
                              end                                

                              else
                              BehCtrl.Vizi.RFmapVectorToBeSent(159:165) = [BehCtrl.Task.distID_ITI,...
                                                      BehCtrl.Vizi.sine_two(2),...
                                                      BehCtrl.Vizi.sine_two(3),...
                                                      1,...
                                                      BehCtrl.Vizi.sine_two(5),...
                                                      BehCtrl.Vizi.sine_two(6),...
                                                      BehCtrl.Vizi.sine_two(7)];                   
                              end
                          case 3
                              if BehCtrl.RF.Mapping
                              BehCtrl.Vizi.RFmapVectorToBeSent(159:165) = [BehCtrl.Task.distID_ITI,...
                                                      BehCtrl.Vizi.sine_three(2),...
                                                      BehCtrl.Vizi.sine_three(3),...
                                                      5,...
                                                      BehCtrl.Vizi.sine_three(5),...
                                                      BehCtrl.Vizi.sine_three(6),...
                                                      BehCtrl.Vizi.sine_three(7)];  

                              BehCtrl.Vizi.RFmapVectorToBeSent = sendItBack(BehCtrl.Vizi.RFmapVectorToBeSent,BehCtrl.Sine.position_three); 
                              if BehCtrl.RF.degMode == 10
                                 BehCtrl.Vizi.RFmapVectorToBeSent = sendNeighborsBack(BehCtrl.Vizi.RFmapVectorToBeSent);
                              end                                

                              else
                              BehCtrl.Vizi.RFmapVectorToBeSent(159:165) = [BehCtrl.Task.distID_ITI,...
                                                      BehCtrl.Vizi.sine_three(2),...
                                                      BehCtrl.Vizi.sine_three(3),...
                                                      1,...
                                                      BehCtrl.Vizi.sine_three(5),...
                                                      BehCtrl.Vizi.sine_three(6),...
                                                      BehCtrl.Vizi.sine_three(7)];                   
                              end
                      end
                case 2
                        switch BehCtrl.Task.gngLocation
                              case 1
                                  if BehCtrl.RF.Mapping
                                  BehCtrl.Vizi.RFmapVectorToBeSent(166:172) = [BehCtrl.Task.distID_ITI,...
                                                          BehCtrl.Vizi.sine_one(2),...
                                                          BehCtrl.Vizi.sine_one(3),...
                                                          5,...
                                                          BehCtrl.Vizi.sine_one(5),...
                                                          BehCtrl.Vizi.sine_one(6),...
                                                          BehCtrl.Vizi.sine_one(7)];  

                                  BehCtrl.Vizi.RFmapVectorToBeSent = sendItBack(BehCtrl.Vizi.RFmapVectorToBeSent,BehCtrl.Sine.position_one); 
                                  if BehCtrl.RF.degMode == 10
                                     BehCtrl.Vizi.RFmapVectorToBeSent = sendNeighborsBack(BehCtrl.Vizi.RFmapVectorToBeSent);
                                  end                                

                                  else
                                  BehCtrl.Vizi.RFmapVectorToBeSent(166:172) = [BehCtrl.Task.distID_ITI,...
                                                          BehCtrl.Vizi.sine_one(2),...
                                                          BehCtrl.Vizi.sine_one(3),...
                                                          1,...
                                                          BehCtrl.Vizi.sine_one(5),...
                                                          BehCtrl.Vizi.sine_one(6),...
                                                          BehCtrl.Vizi.sine_one(7)];                   
                                  end
                              case 2
                                  if BehCtrl.RF.Mapping
                                  BehCtrl.Vizi.RFmapVectorToBeSent(166:172) = [BehCtrl.Task.distID_ITI,...
                                                          BehCtrl.Vizi.sine_two(2),...
                                                          BehCtrl.Vizi.sine_two(3),...
                                                          5,...
                                                          BehCtrl.Vizi.sine_two(5),...
                                                          BehCtrl.Vizi.sine_two(6),...
                                                          BehCtrl.Vizi.sine_two(7)];  

                                  BehCtrl.Vizi.RFmapVectorToBeSent = sendItBack(BehCtrl.Vizi.RFmapVectorToBeSent,BehCtrl.Sine.position_two); 
                                  if BehCtrl.RF.degMode == 10
                                     BehCtrl.Vizi.RFmapVectorToBeSent = sendNeighborsBack(BehCtrl.Vizi.RFmapVectorToBeSent);
                                  end                                

                                  else
                                  BehCtrl.Vizi.RFmapVectorToBeSent(166:172) = [BehCtrl.Task.distID_ITI,...
                                                          BehCtrl.Vizi.sine_two(2),...
                                                          BehCtrl.Vizi.sine_two(3),...
                                                          1,...
                                                          BehCtrl.Vizi.sine_two(5),...
                                                          BehCtrl.Vizi.sine_two(6),...
                                                          BehCtrl.Vizi.sine_two(7)];                   
                                  end
                              case 3
                                  if BehCtrl.RF.Mapping
                                  BehCtrl.Vizi.RFmapVectorToBeSent(166:172) = [BehCtrl.Task.distID_ITI,...
                                                          BehCtrl.Vizi.sine_three(2),...
                                                          BehCtrl.Vizi.sine_three(3),...
                                                          5,...
                                                          BehCtrl.Vizi.sine_three(5),...
                                                          BehCtrl.Vizi.sine_three(6),...
                                                          BehCtrl.Vizi.sine_three(7)];  

                                  BehCtrl.Vizi.RFmapVectorToBeSent = sendItBack(BehCtrl.Vizi.RFmapVectorToBeSent,BehCtrl.Sine.position_three); 
                                  if BehCtrl.RF.degMode == 10
                                     BehCtrl.Vizi.RFmapVectorToBeSent = sendNeighborsBack(BehCtrl.Vizi.RFmapVectorToBeSent);
                                  end                                

                                  else
                                  BehCtrl.Vizi.RFmapVectorToBeSent(166:172) = [BehCtrl.Task.distID_ITI,...
                                                          BehCtrl.Vizi.sine_three(2),...
                                                          BehCtrl.Vizi.sine_three(3),...
                                                          1,...
                                                          BehCtrl.Vizi.sine_three(5),...
                                                          BehCtrl.Vizi.sine_three(6),...
                                                          BehCtrl.Vizi.sine_three(7)];                   
                                  end
                        end
            end
        elseif  BehCtrl.Task.countCycleDist == BehCtrl.Task.numCycleDist + 1
                BehCtrl.Task.countCycleDist = 0; % this is why the saved distractor stimulus count at the last iteration is zero
          
        end
     end
    % count how many times RF mapping is repeated
    BehCtrl.RF.iterationNum = BehCtrl.RF.iterationNum + 1;

end
end
    

% rough RF mapping
function startRoughRFMapping(src,event) % callback of the start button
    global BehCtrl
    % create a text file to save
    updateSaveLocation()
    updateMouseID()
    BehCtrl.Save.TimeStamp = cell2mat(cellfun(@num2str,num2cell(round(clock)),'un',0));
    if BehCtrl.RoughMap.taskStim == 1
        BehCtrl.Save.TextName = strcat(BehCtrl.Save.Location,'/',...
                                           BehCtrl.Save.MouseID,'_RoughRFMap_normal',...
                                           BehCtrl.Save.TimeStamp,...
                                           '.txt');  
    elseif BehCtrl.RoughMap.taskStim == 2 % full stimuli
        BehCtrl.Save.TextName = strcat(BehCtrl.Save.Location,'/',...
                                           BehCtrl.Save.MouseID,'_RoughRFMap_full_',...
                                           BehCtrl.Save.TimeStamp,...
                                           '.txt'); 
    elseif BehCtrl.RoughMap.taskStim == 3 % eight stimuli
        BehCtrl.Save.TextName = strcat(BehCtrl.Save.Location,'/',...
                                           BehCtrl.Save.MouseID,'_RoughRFMap_eight_',...
                                           BehCtrl.Save.TimeStamp,...
                                           '.txt');                                            
    end
    BehCtrl.RoughMap.fileID = fopen(BehCtrl.Save.TextName,'w'); 
     fprintf(BehCtrl.RoughMap.fileID,'%8s\r\n','stimID');
     
    % Create a vector for stimulus order     
     % generate a vector for the order of stimulus location (15 locations x
     % 5 repetitions = 75 times)
     if BehCtrl.RoughMap.taskStim == 1 % task stimuli are used
         % change the value depending on the patch mode
         BehCtrl.RoughMap.StimOrder = generateStimOrder(size(BehCtrl.Task.holePositionMat,1),BehCtrl.RoughMap.NumRepeat);
         % also update the hole position
         BehCtrl.RoughMap.holePosition = BehCtrl.Task.holePositionMat;                                
     elseif BehCtrl.RoughMap.taskStim == 2
         BehCtrl.RoughMap.StimOrder = generateStimOrder(15,BehCtrl.RoughMap.NumRepeat);
         % also update the hole position
         BehCtrl.RoughMap.holePosition = BehCtrl.RoughMap.holePosition_full; 
     elseif BehCtrl.RoughMap.taskStim == 3
         BehCtrl.RoughMap.StimOrder = generateStimOrder(8,BehCtrl.RoughMap.NumRepeat);
         % also update the hole position
         BehCtrl.RoughMap.holePosition = BehCtrl.RoughMap.holePosition_eight;          
     end
     
     % update 'TasksToExecute' of the timer  
     BehCtrl.tRoughRFMap.TasksToExecute = length(BehCtrl.RoughMap.StimOrder); 

    % Reset Stim repetition number
    BehCtrl.RoughMap.doneSofar = 1;
    
    % make the screen gray before Rough RF mapping starts
    BehCtrl.Vizi.GrayWithPD(27) = 3; % white PD patch
    convertAndsendVizivector(BehCtrl.Vizi.GrayWithPD)

    BehCtrl.Vizi.GrayWithPD(27) = 1; % set it back for future use 
    pause(2)    
    
    % start timer
    start(BehCtrl.tRoughRFMap);
end
function sendAndUpdateRoughRFMap(src,event) % timer function of BehCtrl.tRoughRFMap
global BehCtrl
% stimuli is updated here
BehCtrl.RoughMap.ViziVectorTobeSent = BehCtrl.RoughMap.BasicVector;
    % update hole position
    BehCtrl.RoughMap.ViziVectorTobeSent(22) = BehCtrl.RoughMap.holePosition(BehCtrl.RoughMap.StimOrder(BehCtrl.RoughMap.doneSofar),1);
    BehCtrl.RoughMap.ViziVectorTobeSent(23) = BehCtrl.RoughMap.holePosition(BehCtrl.RoughMap.StimOrder(BehCtrl.RoughMap.doneSofar),2);
    % photodiode patch
    BehCtrl.RoughMap.ViziVectorTobeSent(27) = 1; % black
    % stim color
    BehCtrl.RoughMap.ViziVectorTobeSent(3) = datasample([1,3],1); % black or white    
% save stim info
fprintf(BehCtrl.RoughMap.fileID,'%8d\r\n',BehCtrl.RoughMap.StimOrder(BehCtrl.RoughMap.doneSofar));

% start timers
start(BehCtrl.tRoughFirst);  % send the prepared first one, and then prepare the 2nd one
start(BehCtrl.tRoughSecond); % send the prepared 2nd one, and then prepare the gray screen vector
start(BehCtrl.tRoughFinish); % send the gray vector

end
function roughMap1st(event,src)
global BehCtrl
    % send prepared one to Unity  
    convertAndsendVizivector(BehCtrl.RoughMap.ViziVectorTobeSent);

% indicator color    
set(BehCtrl.handles.roughRFIndicator,'BackgroundColor',[0,1,0]); 
% update the next stimuli
if BehCtrl.RoughMap.ViziVectorTobeSent(3) == 1
    BehCtrl.RoughMap.ViziVectorTobeSent(3) = 3;
elseif BehCtrl.RoughMap.ViziVectorTobeSent(3) == 3
    BehCtrl.RoughMap.ViziVectorTobeSent(3) = 1;
end
end
function roughMap2nd(event,src)
global BehCtrl
    % send prepared one to Unity  
    convertAndsendVizivector(BehCtrl.RoughMap.ViziVectorTobeSent);

% update the next stimuli to make it gray (white PD patch)
    BehCtrl.RoughMap.ViziVectorTobeSent(3) = 2;
    BehCtrl.RoughMap.ViziVectorTobeSent(27) = 3; % white PD patch  
end
function roughMapFinish(event,src)
global BehCtrl
    % send prepared one to Unity  
    convertAndsendVizivector(BehCtrl.RoughMap.ViziVectorTobeSent);


% show state in the command line
fprintf('%3d / %3d is done\r\n',BehCtrl.RoughMap.doneSofar,BehCtrl.tRoughRFMap.TasksToExecute)
% update the repetition number
BehCtrl.RoughMap.doneSofar = BehCtrl.RoughMap.doneSofar + 1;
if BehCtrl.tRoughRFMap.TasksExecuted == BehCtrl.tRoughRFMap.TasksToExecute
    fclose(BehCtrl.RoughMap.fileID);
    set(BehCtrl.handles.roughRFIndicator,'BackgroundColor',[1,0,0]);
    disp('all done!')
else
    % indicator color
    set(BehCtrl.handles.roughRFIndicator,'BackgroundColor',[0,0.25,0]); 
end
end
function stimOrder = generateStimOrder(numVariation, numRepeat)
% preallocation
stimOrder = zeros(1,numVariation * numRepeat);
for r = 1:numRepeat
    tempOrder = randperm(numVariation);
    if r > 1 
        if tempOrder(1)==stimOrder(numVariation*(r-1))
            while tempOrder(1)==stimOrder(numVariation*(r-1))
                tempOrder = randperm(numVariation);
            end
            stimOrder(numVariation*r-numVariation+1:numVariation*r) = tempOrder;
        else
            stimOrder(numVariation*r-numVariation+1:numVariation*r) = tempOrder;
        end
    else
        stimOrder(numVariation*r-numVariation+1:numVariation*r) = tempOrder;
    end
    
end
end
%----- Manually show the task stimuli




function clearManualStimuli(event,src) % timer function of BehCtrl.tClearManualStimuli
global BehCtrl
% end with fullscreen Gray
pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Vizi.justGrayString);
pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
    % indicator color
    set(BehCtrl.handles.flashPatch_One,'BackgroundColor',[0,0.25,0]);
    set(BehCtrl.handles.flashPatch_Two,'BackgroundColor',[0,0.25,0]);
    set(BehCtrl.handles.flashPatch_Three,'BackgroundColor',[0,0.25,0]);
 
    set(BehCtrl.handles.roughRFIndicator,'BackgroundColor',[0,0.25,0]); 
    
%     set(BehCtrl.handles.manualShow_TL,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_BL,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_TR,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_BR,'BackgroundColor',[0,0.25,0]);    
%     set(BehCtrl.handles.manualShow_horizontalLeft,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_horizontalRight,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_verticalTop,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_verticalBottom,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_Go,'BackgroundColor',[0,0.25,0]);
%     set(BehCtrl.handles.manualShow_NoGo,'BackgroundColor',[0,0.25,0]);
end

%----- Stim selection: Task
function sendAndUpdateTaskStim(src,event) % TimerFcn of tTaskStim
global BehCtrl

% send a predefined ezvz vector
convertAndsendVizivector(BehCtrl.Vizi.TaskVectorToSend);


% send a digital line for target onset only at the beginning of target
if BehCtrl.Task.TargetFlag == 0 && BehCtrl.Task.woTarget == 0 && BehCtrl.TestMode == false% for defining the onset of target stimuli
    outputSingleScan(BehCtrl.Digsess2,[1])
    BehCtrl.Task.TargetFlag = 1;
end
    
% save info
BehCtrl.RF.toc = toc(BehCtrl.Session.tic);
if BehCtrl.save.startSaving == 1
    if BehCtrl.Task.trialID == 2 || BehCtrl.Task.trialID == 5
        fprintf(BehCtrl.Save.fileID,'%8d %8d %8d %8d %8d %8d %8d %8.4f %8d %8d %8d %8d %8d\r\n',...
            BehCtrl.Task.trialNum,...
            BehCtrl.Task.trialID,...
            BehCtrl.Task.targetLocation,...
            BehCtrl.Task.targetID_current,...
            BehCtrl.RF.Total,...
            BehCtrl.RF.StimID,...
            1,...         % 1 is given when target stimuli are shown
            BehCtrl.RF.toc,...
            BehCtrl.Task.countCycleDist,...
            BehCtrl.Task.distID_ITI,...
            BehCtrl.Task.blockCount,...
            BehCtrl.Task.angleGo,...
            BehCtrl.Task.ITIdistSide);
    elseif BehCtrl.Task.trialID == 3
        fprintf(BehCtrl.Save.fileID,'%8d %8d %8d %8d %8d %8d %8d %8.4f %8d %8d %8d %8d %8d\r\n',...
            BehCtrl.Task.trialNum,...
            BehCtrl.Task.trialID,...
            BehCtrl.Task.targetLocation,...
            BehCtrl.Task.targetID_current,...
            BehCtrl.RF.Total,...
            BehCtrl.RF.StimID,...
            1,...         % 1 is given when target stimuli are shown
            BehCtrl.RF.toc,...
            BehCtrl.Task.countCycleDist,...
            BehCtrl.Task.distID_ITI,...
            BehCtrl.Task.blockCount,...
            BehCtrl.Task.angleNogo,...
            BehCtrl.Task.ITIdistSide);
    end
end
BehCtrl.RF.Total = BehCtrl.RF.Total + 1;
set(BehCtrl.handles.RFTotal,'String',sprintf('Total = %s',num2str(BehCtrl.RF.Total)));

% update stimID
BehCtrl.RF.StimID = BehCtrl.orderInSession(BehCtrl.RF.Total);
set(BehCtrl.handles.StimID,'String',sprintf('%s',num2str(BehCtrl.RF.StimID)));

% update task stimuli
if BehCtrl.RF.Mapping
      if  BehCtrl.Task.sessionHAStimeLimit  
        if BehCtrl.RF.Total > size(BehCtrl.LSNStimMat,1) || BehCtrl.timeIsOver
            disp('task stopped since all stimuli are used')
            taskStopfcn;            
        else
            BehCtrl.Vizi.TaskVectorToSend = BehCtrl.LSNStimMat(BehCtrl.RF.Total,:);
        end
      else
        if BehCtrl.RF.Total > size(BehCtrl.LSNStimMat,1) 
            BehCtrl.Vizi.TaskVectorToSend = BehCtrl.LSNStimMat(mod(BehCtrl.RF.Total,size(BehCtrl.LSNStimMat,1)),:);  
        else
            BehCtrl.Vizi.TaskVectorToSend = BehCtrl.LSNStimMat(BehCtrl.RF.Total,:);
        end
      end
else
    BehCtrl.Vizi.TaskVectorToSend = BehCtrl.Vizi.targetWOsparsenoise;% with black PD patch
end

% set contrast 
BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetID_current;
BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(setdiff([1:5],BehCtrl.Task.targetLocation))) = BehCtrl.Task.distID_current;

% set dist angle
BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(setdiff([1:5],BehCtrl.Task.targetLocation))) = BehCtrl.Task.angleDist;

% put sparse noise sheets in background (if this is true, use avoid
% function below)
if BehCtrl.Task.showSNonTarget == false
    BehCtrl.Vizi.TaskVectorToSend(36:6:156) = 12;
end
% remove distructor
if BehCtrl.Task.removeDistr == true
   BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_size(setdiff([1:5],BehCtrl.Task.gngLocation))) = 0;
end  
% [ONLY FOR TRAINING]
if BehCtrl.Task.changeTargetLocation == true
    if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar') 
        BehCtrl.Vizi.TaskVectorToSend([160,161]) = BehCtrl.Task.currentShiftingTarget_one;
        BehCtrl.Vizi.TaskVectorToSend([167,168]) = BehCtrl.Task.currentShiftingTarget_two;
    else
        BehCtrl.Vizi.TaskVectorToSend([10,11]) = BehCtrl.Task.currentShiftingTarget_bar;%go
        BehCtrl.Vizi.TaskVectorToSend([16,17]) = BehCtrl.Task.currentShiftingTarget_bar;%nogo
        BehCtrl.Vizi.TaskVectorToSend([22,23]) = BehCtrl.Task.currentShiftingTarget_bar;%forground
    end
end
% [ONLY FOR TRAINING2: Add noise]
if BehCtrl.Task.noisyTargetLocation == true
    if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar') 
        BehCtrl.Vizi.TaskVectorToSend(160) = BehCtrl.Sine.position_one(1) + BehCtrl.Task.currentNoiseDeg_x;
        BehCtrl.Vizi.TaskVectorToSend(161) = BehCtrl.Sine.position_one(2) + BehCtrl.Task.currentNoiseDeg_y;
        BehCtrl.Vizi.TaskVectorToSend(167) = BehCtrl.Sine.position_two(1) + BehCtrl.Task.currentNoiseDeg_x;
        BehCtrl.Vizi.TaskVectorToSend(168) = BehCtrl.Sine.position_two(2) + BehCtrl.Task.currentNoiseDeg_y;    
    end
end
% consider if the trial is go or nogo here
switch BehCtrl.Task.trialID 
    case 2  % go
        if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar')    
        %%% if sine wave mode....    
        % 1) define the target location where go stimulus is shown and
        % change the angle of the target patch to be that of go stimulus
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.targetLocation)) = BehCtrl.Task.angleGo;
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetSF;
        % 2) define which sine wave sheets to be brought up (dependent on
        % which mode is being used) and bring them up
            if BehCtrl.RF.Mapping
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
            else
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 1; 
            end
        % 3) get rid of patches within avoid area (might need a separate
        % function)
            if BehCtrl.Task.showSNonTarget == true
                BehCtrl.Vizi.TaskVectorToSend = sendItBack(BehCtrl.Vizi.TaskVectorToSend,BehCtrl.Task.holePositionMat); 
                if BehCtrl.RF.degMode == 10
                    BehCtrl.Vizi.TaskVectorToSend = sendNeighborsBack(BehCtrl.Vizi.TaskVectorToSend);
                end                                
            end

        
        else
        %%% if bar mode with one patch....
        % 1) bring the foreground and grating up
            if BehCtrl.RF.Mapping
                BehCtrl.Vizi.TaskVectorToSend(24) = 5; % foreground sheet with a hole
                BehCtrl.Vizi.TaskVectorToSend(12) = 6; % grating sheet for Go
            else
                BehCtrl.Vizi.TaskVectorToSend(24) = 1; % foreground sheet with a hole
                BehCtrl.Vizi.TaskVectorToSend(12) = 2; % grating sheet for Go                
            end
        end
    
    case 3  % nogo
        if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar')    
        %%% if sine wave mode....    
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.targetLocation)) = BehCtrl.Task.angleNogo;
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetSF;
        % 2) define which sine wave sheets to be brought up (dependent on
        % which mode is being used) and bring them up
            if BehCtrl.RF.Mapping
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
            else
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 1; 
            end      
        % 3) get rid of patches within avoid area (might need a separate
        % function)
            if BehCtrl.Task.showSNonTarget == true
                BehCtrl.Vizi.TaskVectorToSend = sendItBack(BehCtrl.Vizi.TaskVectorToSend,BehCtrl.Task.holePositionMat);
                if BehCtrl.RF.degMode == 10
                    BehCtrl.Vizi.TaskVectorToSend = sendNeighborsBack(BehCtrl.Vizi.TaskVectorToSend);
                end                                
            end          
        else
        %%% if bar mode with one patch....
        % 1) bring the foreground and grating up
            if BehCtrl.RF.Mapping
                BehCtrl.Vizi.TaskVectorToSend(24) = 5; % foreground sheet with a hole
                BehCtrl.Vizi.TaskVectorToSend(18) = 6; % grating sheet for Nogo
            else
                BehCtrl.Vizi.TaskVectorToSend(24) = 1; % foreground sheet with a hole
                BehCtrl.Vizi.TaskVectorToSend(18) = 2; % grating sheet for Nogo                
            end
        end        
    case 5  % catch
        % 1) define the target location where go stimulus is shown and
        % change the angle of the target patch to be that of go stimulus
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.targetLocation)) = BehCtrl.Task.angleGo;
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetSF;
        % Also, show NoGo stimulus at the other locations where nomally go
        % stimulus is shown
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.gngLocation)) = BehCtrl.Task.angleNogo;
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.gngLocation)) = BehCtrl.Task.targetSF; 
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(:)) = BehCtrl.Task.targetID_current; % for adjusting speed
        % 2) define which sine wave sheets to be brought up (dependent on
        % which mode is being used) and bring them up
            if BehCtrl.RF.Mapping
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
            else
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 1; 
            end         
        % 3) get rid of patches within avoid area (might need a separate
        % function) 
            if BehCtrl.Task.showSNonTarget == true
                BehCtrl.Vizi.TaskVectorToSend = sendItBack(BehCtrl.Vizi.TaskVectorToSend,BehCtrl.Task.holePositionMat);  
                if BehCtrl.RF.degMode == 10
                    BehCtrl.Vizi.TaskVectorToSend = sendNeighborsBack(BehCtrl.Vizi.TaskVectorToSend);
                end                                
            end      
end
% consider photodiode patch color (next stimuli)
if BehCtrl.RF.Mapping

  % not sure this change does anything good yet
      if BehCtrl.Task.CurrentPhotodiode == 3 % ie, if the predefined first Task stimulus has white patch
          BehCtrl.Vizi.TaskVectorToSend(27) = 1; % black photodiode patch
          BehCtrl.Task.CurrentPhotodiode = 1; 
      elseif BehCtrl.Task.CurrentPhotodiode == 1 % black
          BehCtrl.Vizi.TaskVectorToSend(27) = 3; % black photodiode patch
          BehCtrl.Task.CurrentPhotodiode = 3;
      end        

else
        BehCtrl.Vizi.TaskVectorToSend(27) = 1; % black photodiode patch
end

end


    function getFirstTaskStim(src,event)
    global BehCtrl
    % check the flag when this function is called
    BehCtrl.Task.FirstStimAfterRF = 1;
    
    if BehCtrl.RF.Mapping
        BehCtrl.Vizi.TaskVectorToSend = BehCtrl.LSNStimMat(BehCtrl.RF.Total + BehCtrl.RF.Limit,:);
    else
        BehCtrl.Vizi.TaskVectorToSend = BehCtrl.Vizi.targetWOsparsenoise;% with black PD patch
    end
    
    % set contrast if multi-contrast mode
%     if strcmp(BehCtrl.Task.contrastMode,'all')
%         BehCtrl.Task.targetID_current = 420 + randi(4);
%         BehCtrl.Vizi.TaskVectorToSend([159,166,173,180,187]) = BehCtrl.Task.targetID_current;
%     end
    % set contrast if multi-contrast mode
    if numel(BehCtrl.Task.targetID_candidate) > 1
       BehCtrl.Task.currentContrast = randi(numel(BehCtrl.Task.targetID_candidate));
       BehCtrl.Task.targetID_current = BehCtrl.Task.targetID_candidate(BehCtrl.Task.currentContrast);
       BehCtrl.Task.distID_current = BehCtrl.Task.distID_candidate(BehCtrl.Task.currentContrast);
       BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetID_current;
       BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(setdiff([1:5],BehCtrl.Task.targetLocation))) = BehCtrl.Task.distID_current;
    else
       BehCtrl.Task.targetID_current = BehCtrl.Task.targetID_candidate; 
       BehCtrl.Task.distID_current = BehCtrl.Task.distID_candidate;
       BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetID_current;
       BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(setdiff([1:5],BehCtrl.Task.targetLocation))) = BehCtrl.Task.distID_current;       
    end    
    % set contrast for distractors (if necessary) % This will be modified
    % later to either show or not show distructor, but not contrast
    if BehCtrl.Task.removeDistr == true
       BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_size(setdiff([1:5],BehCtrl.Task.targetLocation))) = 0;
    end
    % set dist angle
    BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(setdiff([1:5],BehCtrl.Task.targetLocation))) = BehCtrl.Task.angleDist;    
    % [ONLY FOR TRAINING] % This will also be modified to set block
    if BehCtrl.Task.changeTargetLocation == true
        if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar') 
            BehCtrl.Vizi.TaskVectorToSend([160,161]) = BehCtrl.Task.currentShiftingTarget_one;
            BehCtrl.Vizi.TaskVectorToSend([167,168]) = BehCtrl.Task.currentShiftingTarget_two;
        else
            BehCtrl.Vizi.TaskVectorToSend([10,11]) = BehCtrl.Task.currentShiftingTarget_bar;%go
            BehCtrl.Vizi.TaskVectorToSend([16,17]) = BehCtrl.Task.currentShiftingTarget_bar;%nogo
            BehCtrl.Vizi.TaskVectorToSend([22,23]) = BehCtrl.Task.currentShiftingTarget_bar;%forground
        end
    end
    % [ONLY FOR TRAINING2: Add noise]
    if BehCtrl.Task.noisyTargetLocation == true
        if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar') 
            BehCtrl.Vizi.TaskVectorToSend(160) = BehCtrl.Vizi.TaskVectorToSend(160) + BehCtrl.Task.currentNoiseDeg_x;
            BehCtrl.Vizi.TaskVectorToSend(161) = BehCtrl.Vizi.TaskVectorToSend(161) + BehCtrl.Task.currentNoiseDeg_y;
            BehCtrl.Vizi.TaskVectorToSend(167) = BehCtrl.Vizi.TaskVectorToSend(167) + BehCtrl.Task.currentNoiseDeg_x;
            BehCtrl.Vizi.TaskVectorToSend(168) = BehCtrl.Vizi.TaskVectorToSend(168) + BehCtrl.Task.currentNoiseDeg_y;    
        end
    end    
    % put sparse noise sheets in background (if this is true, use avoid
    % function below)
    if BehCtrl.Task.showSNonTarget == false
        BehCtrl.Vizi.TaskVectorToSend(36:6:156) = 12;
    end
    
    % update SF here
    BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetSF;
    
    % consider if the trial is go or nogo here
    switch BehCtrl.Task.trialID 
        case 2  % go
            if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar')    
            %%% if sine wave mode....    
            % 1) define the target location where go stimulus is shown and
            % change the angle of the target patch to be that of go stimulus
            BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.targetLocation)) = BehCtrl.Task.angleGo;
            BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetSF;
            % 2) define which sine wave sheets to be brought up (dependent on
            % which mode is being used) and bring them up
                if BehCtrl.RF.Mapping
                    BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
                else
                    BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 1; 
                end             
            % 3) get rid of patches within avoid area (might need a separate
            % function)(only if BehCtrl.Task.showSNonTarget == true)
                if BehCtrl.Task.showSNonTarget == true
                    BehCtrl.Vizi.TaskVectorToSend = sendItBack(BehCtrl.Vizi.TaskVectorToSend,BehCtrl.Task.holePositionMat);  
                    if BehCtrl.RF.degMode == 10
                        BehCtrl.Vizi.TaskVectorToSend = sendNeighborsBack(BehCtrl.Vizi.TaskVectorToSend);
                    end                
                end

            else
            %%% if bar mode with one patch....
            % 1) bring the foreground and grating up
                if BehCtrl.RF.Mapping
                    BehCtrl.Vizi.TaskVectorToSend(24) = 5; % foreground sheet with a hole
                    BehCtrl.Vizi.TaskVectorToSend(12) = 6; % grating sheet for Go
                else
                    BehCtrl.Vizi.TaskVectorToSend(24) = 1; % foreground sheet with a hole
                    BehCtrl.Vizi.TaskVectorToSend(12) = 2; % grating sheet for Go                
                end
            end

    %         % get rid of patches within avoid area 
    %         BehCtrl.Vizi.TaskVectorToSend = sendItBack(BehCtrl.Vizi.TaskVectorToSend,BehCtrl.Sine.position_one);
    %             if BehCtrl.RF.degMode == 10
    %                 BehCtrl.Vizi.TaskVectorToSend = sendNeighborsBack(BehCtrl.Vizi.TaskVectorToSend);
    %             end
        case 3  % nogo
            if ~strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar')    
            %%% if sine wave mode....    
            % 0) angle is not Nogo angle by default anymore
            % 1) define the target location where go stimulus is shown and
            % change the angle of the target patch to be that of go stimulus
            BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.targetLocation)) = BehCtrl.Task.angleNogo;
            BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetSF;

            % 2) define which sine wave sheets to be brought up (dependent on
            % which mode is being used) and bring them up
            %BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
                if BehCtrl.RF.Mapping
                    BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
                else
                    BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 1; 
                end       
            % 3) get rid of patches within avoid area (might need a separate
            % function)
                if BehCtrl.Task.showSNonTarget == true
                    BehCtrl.Vizi.TaskVectorToSend = sendItBack(BehCtrl.Vizi.TaskVectorToSend,BehCtrl.Task.holePositionMat);
                    if BehCtrl.RF.degMode == 10
                        BehCtrl.Vizi.TaskVectorToSend = sendNeighborsBack(BehCtrl.Vizi.TaskVectorToSend);
                    end                                
                end

            else
            %%% if bar mode with one patch....
            % 1) bring the foreground and grating up
                if BehCtrl.RF.Mapping
                    BehCtrl.Vizi.TaskVectorToSend(24) = 5; % foreground sheet with a hole
                    BehCtrl.Vizi.TaskVectorToSend(18) = 6; % grating sheet for Nogo
                else
                    BehCtrl.Vizi.TaskVectorToSend(24) = 1; % foreground sheet with a hole
                    BehCtrl.Vizi.TaskVectorToSend(18) = 2; % grating sheet for Nogo              
                end
            end
        case 5  % catch trials
        % 1) define the target location where go stimulus is shown and
        % change the angle of the target patch to be that of go stimulus
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.targetLocation)) = BehCtrl.Task.angleGo;
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.targetLocation)) = BehCtrl.Task.targetSF;
        % Also, show NoGo stimulus at the other locations where nomally go
        % stimulus is shown
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_angle(BehCtrl.Task.gngLocation)) = BehCtrl.Task.angleNogo;
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_SF(BehCtrl.Task.gngLocation)) = BehCtrl.Task.targetSF;         
        BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.elements_for_targetID(:)) = BehCtrl.Task.targetID_current; % for adjusting speed
        
        % 2) define which sine wave sheets to be brought up (dependent on
        % which mode is being used) and bring them up        
        %BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
            if BehCtrl.RF.Mapping
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 5; 
            else
                BehCtrl.Vizi.TaskVectorToSend(BehCtrl.Task.tobeBroughtUp) = 1; 
            end         
        % 3) get rid of patches within avoid area (might need a separate
        % function) 
            if BehCtrl.Task.showSNonTarget == true
                BehCtrl.Vizi.TaskVectorToSend = sendItBack(BehCtrl.Vizi.TaskVectorToSend,BehCtrl.Task.holePositionMat);  
                if BehCtrl.RF.degMode == 10
                    BehCtrl.Vizi.TaskVectorToSend = sendNeighborsBack(BehCtrl.Vizi.TaskVectorToSend);
                end                                
            end
        
    end
    % consider photodiode patch color
    if BehCtrl.RF.Mapping
        if BehCtrl.Task.earlyLickFlag == 0 % when defining photodiode patch for the onset of target after ITI
                if BehCtrl.Task.ITIduration > 0
                    if BehCtrl.ITI.CurrentPhotodiode == 1  % ie, if the photodiode patch of the last ITI was black

                            if mod(BehCtrl.RF.Limit,2) == 0
                                BehCtrl.Vizi.TaskVectorToSend(27) = 3; % white photodiode patch
                                BehCtrl.Task.CurrentPhotodiode = 3;
                            else
                               BehCtrl.Vizi.TaskVectorToSend(27) = 1; % black photodiode patch
                               BehCtrl.Task.CurrentPhotodiode = 1;
                            end

                    else

                            if mod(BehCtrl.RF.Limit,2) == 0
                                BehCtrl.Vizi.TaskVectorToSend(27) = 1; % black photodiode patch
                                BehCtrl.Task.CurrentPhotodiode = 1;
                            else
                                BehCtrl.Vizi.TaskVectorToSend(27) = 3; % white photodiode patch
                                BehCtrl.Task.CurrentPhotodiode = 3;
                            end

                    end            

                else
                    if BehCtrl.ITI.CurrentPhotodiode == 1  % ie, if the photodiode patch of the last ITI was black

                            if mod(BehCtrl.RF.Limit,2) == 0
                                BehCtrl.Vizi.TaskVectorToSend(27) = 3; % black photodiode patch
                                BehCtrl.Task.CurrentPhotodiode = 3;
                            else
                               BehCtrl.Vizi.TaskVectorToSend(27) = 1; % white photodiode patch
                               BehCtrl.Task.CurrentPhotodiode = 1;
                            end

                    else
      
                            if mod(BehCtrl.RF.Limit,2) == 0
                                BehCtrl.Vizi.TaskVectorToSend(27) = 1; % white photodiode patch
                                BehCtrl.Task.CurrentPhotodiode = 1;
                            else
                                BehCtrl.Vizi.TaskVectorToSend(27) = 3; % black photodiode patch
                                BehCtrl.Task.CurrentPhotodiode = 3;
                            end

                    end           
                end
        else % when setting the photodiode patch when early lick reset the trial <- corrected 2019 May. check if this is correct
            if BehCtrl.RF.CurrentPhotodiode ==1 % black 
                if mod(BehCtrl.RF.Limit,2) == 1
                     BehCtrl.Vizi.TaskVectorToSend(27) = 3;
                     BehCtrl.Task.CurrentPhotodiode = 3;  
                else
                     BehCtrl.Vizi.TaskVectorToSend(27) = 1;
                     BehCtrl.Task.CurrentPhotodiode = 1; 
                end
            elseif BehCtrl.RF.CurrentPhotodiode ==3
                if mod(BehCtrl.RF.Limit,2) == 0
                     BehCtrl.Vizi.TaskVectorToSend(27) = 3;
                     BehCtrl.Task.CurrentPhotodiode = 3;  
                else
                     BehCtrl.Vizi.TaskVectorToSend(27) = 1;
                     BehCtrl.Task.CurrentPhotodiode = 1; 
                end
            end
        end
    else
        BehCtrl.Vizi.TaskVectorToSend(27) = 1; % black photodiode patch
    end

    end

function addLicklistenerForReward(src,event)
global BehCtrl
BehCtrl.licklistener_Rew = addlistener(BehCtrl.CurrState,'MouseLicked',@OpenValveReward);
% change indicator color
set(BehCtrl.handles.RewZone,'BackgroundColor','green');
end     

function addLicklistenerForPuff(src,event)
global BehCtrl
BehCtrl.licklistener_Puff = addlistener(BehCtrl.CurrState,'MouseLicked',@OpenAirPuff);
% change indicator color
set(BehCtrl.handles.PuffZone,'BackgroundColor','green');
end     



   

%--------------------------------------------------------------------------
%% ----- State
    function SendTaskStim(src,event)
    global BehCtrl
    % new trial indicator and counts
    start(BehCtrl.tNewTrialIndc);   % This makes indicator color change to yellow only for 0.3 sec
    % update trial number
    set(BehCtrl.handles.trialnum ,'String',sprintf('numtrials = %s',num2str(BehCtrl.Task.trialNum)));
    BehCtrl.Task.trialNum = BehCtrl.Task.trialNum + 1;
    
    %GrayTime of previous Trial
    BehCtrl.previousDelay = BehCtrl.Task.DelayTime;
    
    GetVisStimParams

    %GrayTime of current Trial (BehCtrl.Task.DelayTime is updated by GetVisStimParams)
    BehCtrl.currentDelay = BehCtrl.Task.DelayTime;

    %number of how many times the TimerFcn of BehCtrl.tTaskStim is
    %excecuted
    BehCtrl.tTaskStim.TasksToExecute = ceil(BehCtrl.Task.StimDuration/BehCtrl.tTaskStim.Period);

    %stop(BehCtrl.tRew);
    stop(BehCtrl.tEnd);
    %stop(BehCtrl.tPuff);
    %stop(BehCtrl.tAux); % This is not necessary since BehCtrl.tAux timer doesn't have StartDelay and stops immediately after its timerFcn is excecuted.
    
    start(BehCtrl.tAux)
    
    % show current and previous Delay length
    set(BehCtrl.handles.previousDelay,'String',sprintf('%s',num2str(BehCtrl.previousDelay)));
    set(BehCtrl.handles.currentDelay,'String',sprintf('%s',num2str(BehCtrl.currentDelay)));
    end
function GetVisStimParams
global BehCtrl
% Go or NoGo?
if BehCtrl.Task.forceGo == false
    if BehCtrl.Task.continuousNoGo > BehCtrl.Task.forceSwitchTrials - 1 % 10000 by default: 'have go at least N trials after the last go' button
        setToGo;
        disp('Force switch is triggered since NoGos are kept continusously given')
    elseif BehCtrl.Task.continuousGo > BehCtrl.Task.forceSwitchTrials - 1 % 10000 by default: 'have go at least N trials after the last go' button
        setToNoGo;
        disp('Force switch is triggered since Gos are kept continusously given')    
    elseif BehCtrl.Task.continuousNoGo < BehCtrl.Task.avoidGoTrials % -1 by default: 'avoid go for N trials after the last go' button
        setToNoGo;
        disp('Go trials being avioded till reaching threshold')

    else
        if rand < BehCtrl.Task.GoprobOnGoing
            setToGo;
        else
            setToNoGo;
        end
    end
else
    setToGo;
    BehCtrl.Task.forceGo = false;% set it back to false

end

% calculate the duration of RF stimuli period before target
BehCtrl.Task.DelayTime = exprnd(BehCtrl.Task.grayDuration.Mean)+ BehCtrl.Task.grayDuration.Min;                                         
% How many RF stimuli are shown before Go or NoGo stimuli are shown?                                              
BehCtrl.RF.Limit = round(BehCtrl.Task.DelayTime/BehCtrl.RF.OneCycleDuration); 

% calculate delay between lick detection and valve opening
if BehCtrl.Task.ifValveOpensWithDelay == 1
    BehCtrl.Task.ValveDelay = random(BehCtrl.Task.delayDistribution);
else
    BehCtrl.Task.ValveDelay = 0;
end
BehCtrl.tOpenAirPuffValve.StartDelay = BehCtrl.Task.ValveDelay;
BehCtrl.tOpenRewardValve.StartDelay = BehCtrl.Task.ValveDelay;




% create an Vizi vector for the first stimulus in RewZone/PuffZone 
% define stimulus
if BehCtrl.Task.woTarget==0
    getFirstTaskStim  
end
end
function setToGo(src,event)
global BehCtrl
if rand < BehCtrl.Task.Catchprob &&...
        BehCtrl.Task.hitCounterForCatch > BehCtrl.Task.numHitsBeforecatch - 1  % catch trials starts after 15 hit trials
    setToCatch;
    % reset hit counter
    BehCtrl.Task.hitCounterForCatch = 0;
else
    BehCtrl.Task.gotrialnum = BehCtrl.Task.gotrialnum + 1;
    BehCtrl.Task.trialID = 2;% Go
    set(BehCtrl.handles.RewZone,'FontAngle','italic');
    % define the target location
    BehCtrl.Task.targetLocation = BehCtrl.Task.gngLocation;
end
end
function setToCatch(src,event)
global BehCtrl
BehCtrl.Task.catchtrialnum = BehCtrl.Task.catchtrialnum + 1;
BehCtrl.Task.trialID = 5;% Catch go trial
set(BehCtrl.handles.RewZone,'BackgroundColor','red');
% define the location of catch target
BehCtrl.Task.targetLocation = BehCtrl.Task.distLocations(randi(length(BehCtrl.Task.distLocations)));
% block distructor on catch trials
BehCtrl.Task.temporaryBlockDistr = true;
end
function setToNoGo(src,event)
global BehCtrl
    BehCtrl.Task.nogotrialnum = BehCtrl.Task.nogotrialnum + 1;
    BehCtrl.Task.trialID = 3;% NoGo
    set(BehCtrl.handles.PuffZone,'FontAngle','italic');
    BehCtrl.Task.targetLocation = BehCtrl.Task.gngLocation;

end
%     function R = getValueFromExpDecayDist(Min,Mean,Max)
%     % refer to my original function 'Exprnd_MinMax.m' for details
%     R = Min + exprnd(Mean);
%         if R > Max
%                 R = (Min + (Max-Min)*0.8) + (Max - round(Min + (Max-Min)*0.8))*rand(1);
%                 % (Min + (Max-Min)*0.8) is the 80 percentile value; this is taking a random value between 80 percentile and Max
%         end
%         R = round(R,2);
%     end
    
function StartTimers(src,event)
    global BehCtrl
    % create early lick listener
    if BehCtrl.Task.earlyLickResetTrial
        BehCtrl.licklistener_earlyLick = addlistener(BehCtrl.CurrState,'MouseLicked',@resetTrial); 
    end
    % update the indicator color
    set(BehCtrl.handles.RFMap,'BackgroundColor','blue')
    % start RF mapping
    start(BehCtrl.tRFMap)
end

function RewardZone(src,event) % also send UDP package for stimulation here
global BehCtrl
BehCtrl.Task.toc = toc(BehCtrl.Task.tic);
disp('Rew zone')
% delete early lick listener
if isfield(BehCtrl,'licklistener_earlyLick')
    delete(BehCtrl.licklistener_earlyLick)
end

%----send UDP signal to trigger visual stimuli here
start(BehCtrl.tTaskStim);
% add lister for reward   
start(BehCtrl.tlicklistener_Rew);
% update the indicator colors
set(BehCtrl.handles.RewZone,'BackgroundColor','yellow')
set(BehCtrl.handles.RFMap,'BackgroundColor','black')

if BehCtrl.Task.AutoRew && BehCtrl.Task.trialID ~= 5 % AR is not given when it is catch trial
    BehCtrl.tAutoRew.StartDelay = BehCtrl.Task.AutoRewDelay + BehCtrl.Task.GracePeriod;% update StartDelay in case it has changed
    start(BehCtrl.tAutoRew)
end

end
    function PuffZone(src,event) % also send UDP package for stimulation here
    global BehCtrl
    BehCtrl.Task.toc = toc(BehCtrl.Task.tic);
    disp('puff zone')
    % delete early lick listener
    if isfield(BehCtrl,'licklistener_earlyLick')
        delete(BehCtrl.licklistener_earlyLick)
    end

    %----send UDP signal to trigger visual stimuli here
        start(BehCtrl.tTaskStim);
    % add listener for puff   
    % add lister for reward   
    start(BehCtrl.tlicklistener_Puff);
    %BehCtrl.licklistener_Puff = addlistener(BehCtrl.CurrState,'MouseLicked',@OpenAirPuff);  
    % update the indicator colors
    set(BehCtrl.handles.PuffZone,'BackgroundColor','yellow')
    set(BehCtrl.handles.RFMap,'BackgroundColor','black')

    end
function StartITI(src,event) % just to start timer
global BehCtrl
% stop task timers
    stop(BehCtrl.tTaskStim);
% delete another AR listener
if isfield(BehCtrl,'licklistener_AutoRew')
delete(BehCtrl.licklistener_AutoRew);
end
if isfield(BehCtrl,'licklistener_Puff')
delete(BehCtrl.licklistener_Puff);
end
if isfield(BehCtrl,'licklistener_Rew')
delete(BehCtrl.licklistener_Rew);
end
if BehCtrl.Task.CurrentPhotodiode == 3
    BehCtrl.Task.CurrentPhotodiode = 1;
elseif BehCtrl.Task.CurrentPhotodiode == 1
    BehCtrl.Task.CurrentPhotodiode = 3;
end


% define flag for photodiode patch
if BehCtrl.Task.CurrentPhotodiode == 3
    BehCtrl.ITI.CurrentPhotodiode = 1;
elseif BehCtrl.Task.CurrentPhotodiode == 1
    BehCtrl.ITI.CurrentPhotodiode = 3;
end
% predefine the RF stimulus after ITI
    if BehCtrl.RF.Mapping
        % Create a Vizi vector for the next here
              if  BehCtrl.Task.sessionHAStimeLimit % this should be true by default
                if BehCtrl.RF.Total > size(BehCtrl.LSNStimMat,1)
                    % stop the program
                    disp('task stopped since all stimli are used')
                    taskStopfcn;
                elseif BehCtrl.timeIsOver
                    % stop the program
                    disp('task stopped since it reached time limit')
                    taskStopfcn;                    
                else
                    BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.LSNStimMat(BehCtrl.RF.Total,:);
                end
              else
                if BehCtrl.RF.Total > size(BehCtrl.LSNStimMat,1) || BehCtrl.RF.Total > round(BehCtrl.Task.sessionTime*60/BehCtrl.RF.OneCycleDuration)
                    BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.LSNStimMat(mod(BehCtrl.RF.Total,size(BehCtrl.LSNStimMat,1)),:);
                else
                    BehCtrl.Vizi.RFmapVectorToBeSent = BehCtrl.LSNStimMat(BehCtrl.RF.Total,:);
                end
              end
    end

if BehCtrl.Task.ITIduration > 0
    start(BehCtrl.tStartITI)
    BehCtrl.Task.ITI = 1;
else
    start(BehCtrl.tDontStartITI)
end
% flip the StimFlag
if BehCtrl.RF.StimFlag == 0
    BehCtrl.RF.StimFlag = 1;
else
    BehCtrl.RF.StimFlag = 0;
end  
end
    function sendITIGray(src,event)
    global BehCtrl
    % photodiode patch
    if BehCtrl.RF.Mapping
          BehCtrl.Vizi.ITIGrayVectorToSend(27) = BehCtrl.ITI.CurrentPhotodiode;
    else
          BehCtrl.Vizi.ITIGrayVectorToSend(27) = 3; % white photodiode patch
    end
    % make the monitor full gray (but with PD patch)
    convertAndsendVizivector(BehCtrl.Vizi.ITIGrayVectorToSend);

    if BehCtrl.Task.TargetFlag == 1 && BehCtrl.Task.woTarget == 0 && BehCtrl.TestMode == false% for defining the offset of target stimuli(if gray screen for ITI is sent)
    outputSingleScan(BehCtrl.Digsess2,[0])
    BehCtrl.Task.TargetFlag = 0;
    end
   
    % define the next RF's photodiode patch here
    if BehCtrl.ITI.CurrentPhotodiode == 1
        BehCtrl.Vizi.RFmapVectorToBeSent(27) = 3;
        BehCtrl.RF.CurrentPhotodiode = 3;
    elseif BehCtrl.ITI.CurrentPhotodiode == 3
        BehCtrl.Vizi.RFmapVectorToBeSent(27) = 1;
        BehCtrl.RF.CurrentPhotodiode = 1;
    end
    
    % start tEnd timer with StartDelay, which corresponds to ITI length
    if BehCtrl.Task.runningTriggerTrials == false
    % start end timer
    start(BehCtrl.tEnd);
    else
        if mean(BehCtrl.speed(:)) < BehCtrl.Task.SpeedThresh %running speed is not high enough
            stop(BehCtrl.tStartITI)
            start(BehCtrl.tLoopITI) % restart the ITI
        else
            start(BehCtrl.tEnd)
        end
    end
    % update the indicator colors
    set(BehCtrl.handles.ITIZone,'BackgroundColor','blue')
    set(BehCtrl.handles.PuffZone,'BackgroundColor','black')  
    set(BehCtrl.handles.RewZone,'BackgroundColor','black')
    set(BehCtrl.handles.PuffZone,'FontAngle','normal')  
    set(BehCtrl.handles.RewZone,'FontAngle','normal')    
    end   
function dontSendITIGray(src,event)
global BehCtrl
    % define the next RF's photodiode patch here
    if BehCtrl.ITI.CurrentPhotodiode == 1
        BehCtrl.Vizi.RFmapVectorToBeSent(27) = 1;
        BehCtrl.RF.CurrentPhotodiode = 1;
    elseif BehCtrl.ITI.CurrentPhotodiode == 3
        BehCtrl.Vizi.RFmapVectorToBeSent(27) = 3;
        BehCtrl.RF.CurrentPhotodiode = 3;
    end
    % start tEnd timer with StartDelay, which corresponds to ITI length
    if BehCtrl.Task.runningTriggerTrials == false
    % start end timer
    start(BehCtrl.tEnd);
    else
        if mean(BehCtrl.speed(:)) < BehCtrl.Task.SpeedThresh %running speed is not high enough
            stop(BehCtrl.tStartITI)
            start(BehCtrl.tLoopITI) % restart the ITI
        else
            start(BehCtrl.tEnd)
        end
    end
    % update the indicator colors
    set(BehCtrl.handles.ITIZone,'BackgroundColor','blue')
    set(BehCtrl.handles.PuffZone,'BackgroundColor','black')
    set(BehCtrl.handles.RewZone,'BackgroundColor','black')
end       
    
    function loopITIGray(src,event)
    global BehCtrl
        if mean(BehCtrl.speed(:)) > BehCtrl.Task.SpeedThresh %running speed is not high enough
            start(BehCtrl.tEnd)
            start(BehCtrl.tLoopITI)
        end
    end
   
function resetTrial(src,event)
global BehCtrl
if BehCtrl.Task.earlyLickFlag == 0
    % set earlylick flag (This is to avoid miscalculate early lick rate)
    BehCtrl.Task.earlyLickFlag = 1;
    
    % stop Task time counter
    stop(BehCtrl.tTaskCounter); 

    % calculate early lick rate ( #earlyEndedTrial / (#earlyEndedTrial + #completedTrial) )
    BehCtrl.Task.earlyEndTrialnum = BehCtrl.Task.earlyEndTrialnum + 1;
    set(BehCtrl.handles.earlyLickTrials,'String',sprintf('Early Lick trials = %s',num2str(BehCtrl.Task.earlyEndTrialnum)));
    
    % get a new Vizi Vector for the first task trial
    getFirstTaskStim  
  
    % reset the number of how many times RF mapping is repeated
    BehCtrl.RF.iterationNum = 0;
    % start new trial
    BehCtrl.Task.tic=tic;
    % restart Task time counter
    start(BehCtrl.tTaskCounter);
    


end
end
    function RestartTrial(src,event)
    global BehCtrl
    BehCtrl.Task.toc = toc(BehCtrl.Task.tic);% currently this is not used for anything
    % stop Task time counter
    stop(BehCtrl.tTaskCounter);
    % stop task stimulation timers
%     stop(BehCtrl.tTaskStim);

    if  isfield(BehCtrl,'licklistener_Rew') % if the previous trial was a go and there was no reward or auto reward to delete the licklistener
        delete(BehCtrl.licklistener_Rew)
        disp('licklistener_Rew deleted')
    end
    if  isfield(BehCtrl,'licklistener_Puff') 
        delete(BehCtrl.licklistener_Puff)
        disp('licklistener_Puff deleted')
    end
    if  isfield(BehCtrl,'licklistener_earlyLick')
        delete(BehCtrl.licklistener_earlyLick)
    end
    % update FA and misses
    if BehCtrl.Task.trialID==2 && BehCtrl.Task.licked == 0 % miss trial
        % update Go probability
        BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.GoprobOnGoing + BehCtrl.Task.bias; % the bias will increment if mice keep doing shit
        BehCtrl.Task.misses = BehCtrl.Task.misses + 1;
        set(BehCtrl.handles.misses,'String',sprintf('misses = %s',num2str(BehCtrl.Task.misses)));
    elseif BehCtrl.Task.trialID==2 && BehCtrl.Task.licked == 1
        % update Go probability
        BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.Goprob; % reset the bias
        BehCtrl.Task.hits = BehCtrl.Task.hits + 1;
        BehCtrl.Task.hitCounterForCatch = BehCtrl.Task.hitCounterForCatch + 1;
        set(BehCtrl.handles.hits,'String',sprintf('hits = %s',num2str(BehCtrl.Task.hits)));
        set(BehCtrl.handles.hitCounterForCatch,'String',sprintf('%s',num2str(BehCtrl.Task.hitCounterForCatch)));
    elseif BehCtrl.Task.trialID==3 && BehCtrl.Task.licked == 1
        % update Go probability
        BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.GoprobOnGoing - BehCtrl.Task.bias; % the bias will increment if mice keep doing shit        
        BehCtrl.Task.falsealarms = BehCtrl.Task.falsealarms + 1;
        set(BehCtrl.handles.falsealarms,'String',sprintf('falsealarms = %s',num2str(BehCtrl.Task.falsealarms)));
    else % correct rejection
        % update G~o probability
        BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.Goprob; % reset the bias
    end
    % update performance on catch trials
    if BehCtrl.Task.trialID==5 
        if BehCtrl.Task.licked == 0 % miss trial
           BehCtrl.Task.missOnCatch = BehCtrl.Task.missOnCatch + 1; 
           set(BehCtrl.handles.missOnCatch,'String',sprintf('miss_catch = %s',num2str(BehCtrl.Task.missOnCatch)));
        else % hit trial
           BehCtrl.Task.hitOnCatch = BehCtrl.Task.hitOnCatch + 1; 
           set(BehCtrl.handles.hitOnCatch,'String',sprintf('hit_catch = %s',num2str(BehCtrl.Task.hitOnCatch)));
        end
    end
    % correct if over biased
    if BehCtrl.Task.GoprobOnGoing > 1
        BehCtrl.Task.GoprobOnGoing = 1;
    elseif BehCtrl.Task.GoprobOnGoing < -1
        BehCtrl.Task.GoprobOnGoing = -1;
    end
    % update missrate and farate plots
    BehCtrl.Task.MSRate = [BehCtrl.Task.MSRate , BehCtrl.Task.misses / BehCtrl.Task.gotrialnum];
    BehCtrl.Task.FARate = [BehCtrl.Task.FARate , BehCtrl.Task.falsealarms / BehCtrl.Task.nogotrialnum]; % are these 2 lines better here or inside if?

    if (numel(BehCtrl.Task.MSRate) > 50) && (numel(BehCtrl.Task.FARate) > 50)
        plot(BehCtrl.handles.MS, BehCtrl.Task.MSRate(end-50:end),'r*-')
        plot(BehCtrl.handles.FA, BehCtrl.Task.FARate(end-50:end),'b*-')
        BehCtrl.handles.FA.Title.String = 'FA';
        BehCtrl.handles.MS.Title.String = 'Miss';
    else
        plot(BehCtrl.handles.MS, BehCtrl.Task.MSRate,'r*-')
        plot(BehCtrl.handles.FA, BehCtrl.Task.FARate,'b*-')
        BehCtrl.handles.FA.Title.String = 'FA';
        BehCtrl.handles.MS.Title.String = 'Miss';
    end
    drawnow
    % change indicator colors to default mode
    set(BehCtrl.handles.ITIZone,'BackgroundColor','black')
    % reset the number of how many times RF mapping is repeated
    BehCtrl.RF.iterationNum = 0;
    % reset licking flag
    BehCtrl.Task.licked = 0;
    % reset earlylick flag (This is to avoid miscalculate early lick rate)
    BehCtrl.Task.earlyLickFlag = 0;
%     % reset RF stim flag
%     BehCtrl.RF.StimFlag = 0;  % stop resetting stim flag
    BehCtrl.Task.ITI = 0;
    % reset distructor counter (just in case)
    BehCtrl.Task.countCycleDist = 0;
    % start new trial
    BehCtrl.Task.tic=tic;
    % start Task time counter
    start(BehCtrl.tTaskCounter);
    % count continuous Go
    if BehCtrl.Task.trialID == 2
        BehCtrl.Task.continuousGo = BehCtrl.Task.continuousGo + 1;
        BehCtrl.Task.continuousNoGo = 0;
    elseif BehCtrl.Task.trialID == 3
        BehCtrl.Task.continuousNoGo = BehCtrl.Task.continuousNoGo + 1;
        BehCtrl.Task.continuousGo = 0;
    end
    % update the indicator of current Go probability
    set(BehCtrl.handles.currentGoProb,'String',num2str(BehCtrl.Task.GoprobOnGoing));
    % [ONLY FOR TRAINING]
    if BehCtrl.Task.changeTargetLocation == true || BehCtrl.Task.noisyTargetLocation == true
        BehCtrl.Task.cumTrialNumAfterChange = BehCtrl.Task.cumTrialNumAfterChange + 1;
        if BehCtrl.Task.cumTrialNumAfterChange == BehCtrl.Task.NumTrialsToChangeTarget
            BehCtrl.Task.cumTrialNumAfterChange = 0; % reset
            % update locations
            if strcmp(BehCtrl.Task.numPatchMode,'2_patch')
                BehCtrl.Task.usedOnlyhereA = randi(4);
                BehCtrl.Task.usedOnlyhereB = [1,2,3,4];
                BehCtrl.Task.usedOnlyhereB = BehCtrl.Task.usedOnlyhereB(BehCtrl.Task.usedOnlyhereB ~= BehCtrl.Task.usedOnlyhereA);
                BehCtrl.Task.currentShiftingTarget_one = BehCtrl.Task.targetLocations_twoPatch(BehCtrl.Task.usedOnlyhereA,:) + 25*randn(1);   
                BehCtrl.Task.currentShiftingTarget_two = BehCtrl.Task.targetLocations_twoPatch(BehCtrl.Task.usedOnlyhereB(randi(3)),:)+ 25*randn(1);  
            elseif strcmp(BehCtrl.Task.numPatchMode,'1_patch')
                BehCtrl.Task.currentShiftingTarget_one = [-400 + 800*rand(1),-350 + 700*rand(1)];
            elseif strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar') 
                BehCtrl.Task.currentShiftingTarget_bar = [-400 + 800*rand(1),-300 + 600*rand(1)];
            end
            % update noise
            BehCtrl.Task.currentNoiseDeg_x = BehCtrl.Task.noiseOnTarget*rand(1)*sign(rand(1)-0.5);
            BehCtrl.Task.currentNoiseDeg_y = BehCtrl.Task.noiseOnTarget*rand(1)*sign(rand(1)-0.5);
        end
        % show how many trials are remaining before change
        set(BehCtrl.handles.remainingTrials,'String',num2str(BehCtrl.Task.NumTrialsToChangeTarget - BehCtrl.Task.cumTrialNumAfterChange));
    else
        if BehCtrl.Task.cumTrialNumAfterChange > 0
            BehCtrl.Task.cumTrialNumAfterChange = 0; % reset
        end
        
    end
    % [FOR block structure]
    if BehCtrl.Task.BlockActivated == true
        BehCtrl.Task.blockTrialCount = BehCtrl.Task.blockTrialCount + 1;

        % update counter
        % check if need to switch block
        if BehCtrl.Task.blockTrialCount == BehCtrl.Task.blockSize + 1
            BehCtrl.Task.blockCount = BehCtrl.Task.blockCount + 1;
            if BehCtrl.Task.blockCount == BehCtrl.Task.numBlocks % number of blocks reached the limit
                BehCtrl.Task.blockSize = 99999;
                set(BehCtrl.handles.blockSize,'enable','off','string',sprintf('%s',num2str(BehCtrl.Task.blockSize)));
            end
            BehCtrl.Task.blockTrialCount = 1;
            % reset num hits before catch
            BehCtrl.Task.hitCounterForCatch = 0;
            % switch go location
            BehCtrl.Task.gngLocation = BehCtrl.Task.distLocations(randi(length(BehCtrl.Task.distLocations),1));
            BehCtrl.Task.distLocations = setdiff(BehCtrl.Task.allLocation,BehCtrl.Task.gngLocation);% locations for distructor
            % the first trial after switching is GO
            BehCtrl.Task.forceGo = true;
            % show no distructor during sparse noise period on the
            % switching trial
            BehCtrl.Task.temporaryBlockDistr = true;
            % reset Go probability
            BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.Goprob;

            switch BehCtrl.Task.gngLocation
                case 1
                   set(BehCtrl.handles.patchLocation_One,'String','GO','BackgroundColor', 'green'); 
                   set(BehCtrl.handles.patchLocation_Two,'String','Distractor','BackgroundColor', 'yellow');    
                   set(BehCtrl.handles.patchLocation_Three,'String','Distractor','BackgroundColor', 'yellow');  
                   set(BehCtrl.handles.slider_one_azimuth,'backgroundcolor','green');
                   set(BehCtrl.handles.slider_two_azimuth,'backgroundcolor','yellow');
                   set(BehCtrl.handles.slider_one_altitude,'backgroundcolor','green');
                   set(BehCtrl.handles.slider_two_altitude,'backgroundcolor','yellow');                   
                   if strcmp(BehCtrl.Task.numPatchMode,'3_patch')
                       set(BehCtrl.handles.slider_three_azimuth,'backgroundcolor','yellow');
                       set(BehCtrl.handles.slider_three_altitude,'backgroundcolor','yellow'); 
                   end
                case 2
                   set(BehCtrl.handles.patchLocation_One,'String','Distractor','BackgroundColor', 'yellow'); 
                   set(BehCtrl.handles.patchLocation_Two,'String','GO','BackgroundColor', 'green');    
                   set(BehCtrl.handles.patchLocation_Three,'String','Distractor','BackgroundColor', 'yellow');  
                   set(BehCtrl.handles.slider_one_azimuth,'backgroundcolor','yellow');
                   set(BehCtrl.handles.slider_two_azimuth,'backgroundcolor','green');
                   set(BehCtrl.handles.slider_one_altitude,'backgroundcolor','yellow');
                   set(BehCtrl.handles.slider_two_altitude,'backgroundcolor','green');                   
                   if strcmp(BehCtrl.Task.numPatchMode,'3_patch')
                       set(BehCtrl.handles.slider_three_azimuth,'backgroundcolor','yellow');
                       set(BehCtrl.handles.slider_three_altitude,'backgroundcolor','yellow'); 
                   end                   
                case 3
                   set(BehCtrl.handles.patchLocation_One,'String','Distractor','BackgroundColor', 'yellow'); 
                   set(BehCtrl.handles.patchLocation_Two,'String','Distractor','BackgroundColor', 'yellow');    
                   set(BehCtrl.handles.patchLocation_Three,'String','GO','BackgroundColor', 'green');  
                   set(BehCtrl.handles.slider_one_azimuth,'backgroundcolor','yellow');
                   set(BehCtrl.handles.slider_two_azimuth,'backgroundcolor','yellow');
                   set(BehCtrl.handles.slider_one_altitude,'backgroundcolor','yellow');
                   set(BehCtrl.handles.slider_two_altitude,'backgroundcolor','yellow');                   

                       set(BehCtrl.handles.slider_three_azimuth,'backgroundcolor','green');
                       set(BehCtrl.handles.slider_three_altitude,'backgroundcolor','green'); 
         
            end
        else
            if BehCtrl.Task.temporaryBlockDistr == true
                BehCtrl.Task.temporaryBlockDistr = false;
            end
            
        end
            % update gui
            set(BehCtrl.handles.blockTrialCounter,'String',sprintf('%s',num2str(BehCtrl.Task.blockTrialCount)));
            set(BehCtrl.handles.blockCounter,'String',sprintf('%s',num2str(BehCtrl.Task.blockCount)));   
    else
            if BehCtrl.Task.temporaryBlockDistr == true
                BehCtrl.Task.temporaryBlockDistr = false;
            end        
    end
    % trigger state
    triggerTrialStart(BehCtrl.CurrState)
    end

%--------------------------------------------------------------------------
%% ----- valve
function OpenValveReward(src,event)
global BehCtrl
BehCtrl.Task.licked = 1;
if BehCtrl.Task.ifBlockLFRreward == false
    start(BehCtrl.tOpenRewardValve);
%     outputSingleScan(BehCtrl.Digsess,[1,0])
%     disp('valve opened')
%     BehCtrl.tValveClose.StartDelay = BehCtrl.Task.ValveDuration;
%     start(BehCtrl.tValveClose)
end
stop(BehCtrl.tAutoRew)
delete(BehCtrl.licklistener_Rew)

end
function OpenAirPuff(src,event)
global BehCtrl
% for counting as FA (early lick is not counted as FA)
BehCtrl.Task.licked = 1;
if BehCtrl.Task.PuffOnFA && BehCtrl.Task.PuffFlag == 0
    BehCtrl.Task.PuffFlag = 1;
    start(BehCtrl.tOpenAirPuffValve);
%     outputSingleScan(BehCtrl.Digsess,[0,1])
%     disp('air valve opened')
%     BehCtrl.tAirValveClose.StartDelay = BehCtrl.Task.AirValveDuration;
%     start(BehCtrl.tAirValveClose)      
end
%delete(BehCtrl.licklistener_Puff)
end
function OpenValveRewardAutoRew(src,event)
global BehCtrl
disp('valve auto opened')
BehCtrl.autoRewFlag = 1;
outputSingleScan(BehCtrl.Digsess,[1,0])
delete(BehCtrl.licklistener_Rew)
BehCtrl.tValveCloseAutoRew.StartDelay = BehCtrl.Task.AutoRewValveDuration;
start(BehCtrl.tValveCloseAutoRew)
end
function closeAutoRew(src,event)
global BehCtrl
outputSingleScan(BehCtrl.Digsess,[0,0])
if BehCtrl.autoRewFlag == 1
    BehCtrl.licklistener_AutoRew = addlistener(BehCtrl.CurrState,'MouseLicked',@OpenValveOnceMore); % listener for opening valve twice if licked for autoRew
    BehCtrl.autoRewFlag = 0;
else
    delete(BehCtrl.licklistener_AutoRew);
    stop(BehCtrl.tValveCloseAutoRewOnceMore)
end
stop(BehCtrl.tValveCloseAutoRew)
end
function OpenValveOnceMore(src,event)
global BehCtrl
disp('one more autoRew since licked')
outputSingleScan(BehCtrl.Digsess,[1,0])
BehCtrl.tValveCloseAutoRewOnceMore.StartDelay = BehCtrl.Task.AutoRewValveDuration;
start(BehCtrl.tValveCloseAutoRewOnceMore)
end
function OpenValveRewardManual(src,event)
global BehCtrl
disp('valve manually opened')
outputSingleScan(BehCtrl.Digsess,[1,0])
start(BehCtrl.tValveClose)
end
function OpenValvePuffManual(src,event)
global BehCtrl
disp('Puff valve manually opened')
outputSingleScan(BehCtrl.Digsess,[0,1])
start(BehCtrl.tAirValveClose)
end
function OpenValveManual(src,event)
global BehCtrl
disp('valve manually opened')
outputSingleScan(BehCtrl.Digsess,[1,0])
set(BehCtrl.handles.Valve,'Backgroundcolor','yellow');
end
function CloseValveManual(src,event)
global BehCtrl
disp('valve manually closed')
outputSingleScan(BehCtrl.Digsess,[0,0])
set(BehCtrl.handles.Valve,'Backgroundcolor','black');
end
%-------------------------------------------------------------------------- 
%% ----- Save
function updateSaveLocation(src,event)
global BehCtrl
BehCtrl.Save.Location = get(BehCtrl.handles.SaveLocation,'String');
get(BehCtrl.handles.SaveLocation,'String')
end
function updateMouseID(src,event)
global BehCtrl
BehCtrl.Save.MouseID = get(BehCtrl.handles.MouseID,'String');
get(BehCtrl.handles.MouseID,'String')
end    
function splitFile(src,event)
global BehCtrl
    BehCtrl.Save.TimeStamp = cell2mat(cellfun(@num2str,num2cell(round(clock)),'un',0));
    BehCtrl.Save.TextName = strcat(BehCtrl.Save.Location,'/',...
                                   BehCtrl.Save.MouseID,'_StimInfo_',...
                                   BehCtrl.Save.TimeStamp,...
                                   '.txt');                           
    BehCtrl.Save.fileID = fopen(BehCtrl.Save.TextName,'w'); 
    fprintf(BehCtrl.Save.fileID,'%8s %8s %9s %12s %8s %8s %8s %12s %13s %13s %13s %13s %13s\r\n',...
    'Trial#',...
    'TrialID',...
    'TgtLocation',...
    'TargetID',... % stimulus ID of target. Get info on contrast from here
    'TotalRF#',...
    'StimID',...
    'Target',... % 1 is given when target stimuli are shown
    'sessionTime',...
    'ITIdistCount',...
    'ITIdistCont',...
    'blockCount',...
    'TargetAngle',...
    'DistLocation');% This is added on 2020-07-17 (afterLockdown == true)
    BehCtrl.Save.BinName = strcat(BehCtrl.Save.Location,'/',...
                                   BehCtrl.Save.MouseID,'_AiData_',...
                                   BehCtrl.Save.TimeStamp,...
                                   '.bin');      
    BehCtrl.Save.AI = fopen(BehCtrl.Save.BinName,'w+');

end
function startSaving(src,event)
global BehCtrl
if BehCtrl.handles.startSaving.Value == 1 % if the button is pressed: by default (without pressing the button), the Value is zero

    BehCtrl.save.flag = BehCtrl.save.flag + 1; % this is zero by default and odd number if save button is pressed
    set(BehCtrl.handles.startSaving,'BackgroundColor','yellow','String','saving...','ForegroundColor','black');
% create a new file    
    BehCtrl.Save.TimeStamp = cell2mat(cellfun(@num2str,num2cell(round(clock)),'un',0));
    BehCtrl.Save.TextName = strcat(BehCtrl.Save.Location,'/',...
                                   BehCtrl.Save.MouseID,'_StimInfo_',...
                                   BehCtrl.Save.TimeStamp,...
                                   '.txt');                           
    BehCtrl.Save.fileID = fopen(BehCtrl.Save.TextName,'w'); 
    fprintf(BehCtrl.Save.fileID,'%8s %8s %9s %12s %8s %8s %8s %12s %13s %13s %13s %13s %13s\r\n',...
    'Trial#',...
    'TrialID',...
    'TgtLocation',...
    'TargetID',... % stimulus ID of target. Get info on contrast from here
    'TotalRF#',...
    'StimID',...
    'Target',... % 1 is given when target stimuli are shown
    'sessionTime',...
    'ITIdistCount',...
    'ITIdistCont',...
    'blockCount',...
    'TargetAngle',...
    'DistLocation');% create a header of text file

    BehCtrl.Save.BinName = strcat(BehCtrl.Save.Location,'/',...
                                   BehCtrl.Save.MouseID,'_AiData_',...
                                   BehCtrl.Save.TimeStamp,...
                                   '.bin');      
    BehCtrl.Save.AI = fopen(BehCtrl.Save.BinName,'w+');
    % save meta data
    saveMetaData;

    BehCtrl.save.startSaving = 1;
    
else
    BehCtrl.save.startSaving = 0;
    set(BehCtrl.handles.startSaving,'BackgroundColor','red','String','!Save!','ForegroundColor','white');
    fclose(BehCtrl.Save.fileID);
    fclose(BehCtrl.Save.AI);
end
end

function saveMetaData(src,event)
global BehCtrl
    BehCtrl.Save.metaDataName = strcat(BehCtrl.Save.Location,'/',...
                                   BehCtrl.Save.MouseID,'_metaData_',...
                                   BehCtrl.Save.TimeStamp,...
                                   '.mat');
       % related to Target stim properties   
       %--- task visual stimulus
       metaData.GNG.angleGo = BehCtrl.Task.angleGo;
       metaData.GNG.angleNogo = BehCtrl.Task.angleNogo;
       metaData.GNG.angleDist = BehCtrl.Task.angleDist;
       metaData.GNG.contrast = BehCtrl.Task.targetID_candidate; % <- is this correct??
       metaData.GNG.targetSF = BehCtrl.Task.targetSF;
       metaData.GNG.distSF = BehCtrl.Task.distSF;
       metaData.GNG.targetSize = BehCtrl.Task.Size;
       metaData.GNG.numPatch = BehCtrl.Task.numPatchMode;
       metaData.GNG.targetLocations = BehCtrl.Task.holePositionMat;
       %metaData.gngLocation = BehCtrl.Task.gngLocation;
       metaData.GNG.barPatchSize = BehCtrl.Bar.holeSize;
      

       
       %--- sparse noise
       metaData.SN.type = BehCtrl.RF.degMode; % either 10 deg or 5 deg mode
       metaData.SN.duration = BehCtrl.RF.OneCycleDuration;
       metaData.SN.fileNumber = BehCtrl.RF.fileNumber;
       metaData.SN.timeDistr= [BehCtrl.Task.grayDuration.Min,...
                                   BehCtrl.Task.grayDuration.Mean,...
                                   BehCtrl.Task.grayDuration.Max]; 
       metaData.SN.shownOnTarget = BehCtrl.Task.showSNonTarget;                         
       
       %--- parameter task related
       metaData.Param.valveDurationRew = BehCtrl.Task.ValveDuration;
       metaData.Param.valveDurationAuto = BehCtrl.Task.AutoRewValveDuration;
       metaData.Param.PuffDuration = BehCtrl.Task.AirValveDuration;       
       metaData.Param.delayMean = BehCtrl.Task.delayMean;
       metaData.Param.delaySD = BehCtrl.Task.delaySD;
       metaData.Param.delayMin = BehCtrl.Task.delayMin;
       metaData.Param.delayMax = BehCtrl.Task.delayMax;      
       metaData.Param.targetDuration = BehCtrl.Task.StimDuration;
       metaData.Param.autoRewDelay = BehCtrl.Task.AutoRewDelay;     
       metaData.Param.GoProbability = BehCtrl.Task.Goprob;
       metaData.Param.catchProbability = BehCtrl.Task.Catchprob;           
       metaData.Param.howManyHitsBeforeStartingCatch = BehCtrl.Task.numHitsBeforecatch;       
       metaData.Param.LickThreshold = BehCtrl.Task.LickThresh;       
       metaData.Param.ITIDuration = BehCtrl.Task.ITIduration; 
       metaData.Param.gracePeriod = BehCtrl.Task.GracePeriod;    
       metaData.Param.blockSize = BehCtrl.Task.blockSize;
       metaData.Param.speedThreshold = BehCtrl.Task.SpeedThresh;
       metaData.Param.sessionTime = BehCtrl.Task.sessionTime;
       metaData.Param.forceSwitchAfterNcontinuous = BehCtrl.Task.forceSwitchTrials;
       metaData.Param.avoidGoForNtrialsAfterLastGo = BehCtrl.Task.avoidGoTrials;
       metaData.Param.bias = BehCtrl.Task.bias;
       metaData.Param.prob_ITIdistractor = BehCtrl.Task.randomDistProb;      
       metaData.Param.distDuration = BehCtrl.Task.durationDist;
       % related to setting mode
       metaData.Setting.PuffOnFA = BehCtrl.Task.PuffOnFA;
       metaData.Setting.AutoRewGiven = BehCtrl.Task.AutoRew;
       metaData.Setting.ResetByEarlyLick = BehCtrl.Task.earlyLickResetTrial;
       metaData.Setting.LFRGiven = BehCtrl.Task.ifBlockLFRreward;
       metaData.Setting.RunningTriggerTrials = BehCtrl.Task.runningTriggerTrials;
       metaData.Setting.ifValveOpensWithDelay = BehCtrl.Task.ifValveOpensWithDelay; 
       metaData.Setting.ifTimeLimitActivated = BehCtrl.Task.sessionHAStimeLimit;
       metaData.Setting.distractorOnTarget = BehCtrl.Task.removeDistr;
       metaData.Setting.ITIdistractor = BehCtrl.Task.showITIdistractor;
       metaData.Setting.ITIdistractorONattended = BehCtrl.Task.ITIdistONattended;

     if BehCtrl.save.startSaving == 0
         save(BehCtrl.Save.metaDataName,'metaData');  
     else
         save(BehCtrl.Save.metaDataName,'metaData','-append');
     end
end
%--------------------------------------------------------------------------
%% ----- uicontrol Callback functions
%---------------- subfunctions for RF Mapping
function RFMappingONOFF(src,event)
global BehCtrl
if BehCtrl.handles.RFMappingONOFF.Value == 1
% ---- update ui
set(BehCtrl.handles.RFMappingONOFF,...
                                'String','RF Mapping OFF',...
                                'BackgroundColor',[0.6 0.6 0]); % 
% ---- now RFMapping is false
BehCtrl.RF.Mapping = false;
% ---- disable TimeLimit 
set(BehCtrl.handles.sessionTimeLimit,'enable','off');

else
% ---- update ui
set(BehCtrl.handles.RFMappingONOFF,...
                                'String','RF Mapping ON...',...
                                'BackgroundColor','yellow'); % 
% ---- now RFMapping is true
BehCtrl.RF.Mapping = true;  
% ---- disable TimeLimit 
set(BehCtrl.handles.sessionTimeLimit,'enable','on');
end
end
function updateRFStimType(src,event)
global BehCtrl
val = src.Value;
type = src.String;
% update here
BehCtrl.RF.StimType = type{val};
%Refer to 'https://uk.mathworks.com/help/matlab/ref/uicontrol.html'
if strcmp(BehCtrl.RF.StimType,'SparseNoise_5deg') % copy default setting
    setTo5degMode;
elseif strcmp(BehCtrl.RF.StimType,'SparseNoise_10deg')
    setTo10degMode;
end
end
function setTo5degMode(src,event)
global BehCtrl
    BehCtrl.RF.degMode = 5;
    BehCtrl.Bar.holeSize = 3000;
    BehCtrl.LSNvectorLibrary = load('LSNvectorLibrary_ATTEN_5deg.mat','AllvectorsToBeSent','patchMonitorMat','orderInSession');
    for I = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,1)
        for III = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,3)
            % 5 deg
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,3:8,III) = BehCtrl.Vizi.background;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,9:14,III) = BehCtrl.Vizi.grating1;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,15:20,III) = BehCtrl.Vizi.grating2;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,21:26,III) = BehCtrl.Vizi.foreground;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,27:32,III) = BehCtrl.Vizi.photodiode;
            % sine waves
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,159:165,III) = BehCtrl.Vizi.sine_one;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,166:172,III) = BehCtrl.Vizi.sine_two;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,173:179,III) = BehCtrl.Vizi.sine_three;
            % make target patch bigger
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,26,III) = BehCtrl.Bar.holeSize;
        end
    end    


    BehCtrl.LSNStimMat = BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(:,:,BehCtrl.RF.fileNumber);
    % update the size of grating sheet
    BehCtrl.LSNStimMat(:,14) = 43; 

    
    BehCtrl.orderInSession = BehCtrl.LSNvectorLibrary.orderInSession(BehCtrl.RF.fileNumber,:);

    BehCtrl.RF.OneCycleDuration = 0.30;
    set(BehCtrl.handles.RFStimDuration,'String',num2str(BehCtrl.RF.OneCycleDuration));
        % change parameters that are dependent on OneCycleDuration and
        % StimLength
        BehCtrl.tRFMap.Period = BehCtrl.RF.OneCycleDuration;
        BehCtrl.tTaskStim.Period = BehCtrl.RF.OneCycleDuration;
        BehCtrl.RF.Limit = round(BehCtrl.Task.DelayTime/BehCtrl.RF.OneCycleDuration);   
        BehCtrl.tDontStartITI.StartDelay = BehCtrl.RF.OneCycleDuration;
   
    % update useless zone    
    BehCtrl.Vizi.useless_left = 6;  %7 (10deg mode)
    BehCtrl.Vizi.useless_right = 4; %4
    BehCtrl.Vizi.useless_top = 2;   %3
    BehCtrl.Vizi.useless_bottom = 2;%2
    BehCtrl.Vizi.usefulMat = ones(18,32);
        BehCtrl.Vizi.usefulMat(:,[1:BehCtrl.Vizi.useless_left,end-BehCtrl.Vizi.useless_right+1:end]) = 0;
        BehCtrl.Vizi.usefulMat([1:BehCtrl.Vizi.useless_top,end-BehCtrl.Vizi.useless_bottom+1:end],:) = 0;
        BehCtrl.Vizi.patchMat_x = BehCtrl.patchMat.patchMonitorMat_x .* BehCtrl.Vizi.usefulMat;
        BehCtrl.Vizi.patchMat_y = BehCtrl.patchMat.patchMonitorMat_y .* BehCtrl.Vizi.usefulMat;
    disp('RF Mode: SparseNoise_5deg')
end
function setTo10degMode(src,event)
global BehCtrl
    BehCtrl.RF.degMode = 10;
    BehCtrl.Bar.holeSize = 4500; %30 DEG
    BehCtrl.LSNvectorLibrary = load('LSNvectorLibrary_ATTEN_10deg.mat','AllvectorsToBeSent','patchMonitorMat','orderInSession');
    for I = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,1)
        for III = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,3)
            % 5 deg
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,3:8,III) = BehCtrl.Vizi.background;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,9:14,III) = BehCtrl.Vizi.grating1;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,15:20,III) = BehCtrl.Vizi.grating2;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,21:26,III) = BehCtrl.Vizi.foreground;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,27:32,III) = BehCtrl.Vizi.photodiode;
            % sine waves
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,159:165,III) = BehCtrl.Vizi.sine_one;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,166:172,III) = BehCtrl.Vizi.sine_two;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,173:179,III) = BehCtrl.Vizi.sine_three;
            % make target patch bigger
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,26,III) = BehCtrl.Bar.holeSize;
        end
    end    
    
    BehCtrl.LSNStimMat = BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(:,:,BehCtrl.RF.fileNumber);
    % update the size of grating sheet
    BehCtrl.LSNStimMat(:,14) = 43;

    
    BehCtrl.orderInSession = BehCtrl.LSNvectorLibrary.orderInSession(BehCtrl.RF.fileNumber,:);

    BehCtrl.RF.OneCycleDuration = 0.3;
    set(BehCtrl.handles.RFStimDuration,'String',num2str(BehCtrl.RF.OneCycleDuration));
        % change parameters that are dependent on OneCycleDuration and
        % StimLength
        BehCtrl.tRFMap.Period = BehCtrl.RF.OneCycleDuration;
        BehCtrl.tTaskStim.Period = BehCtrl.RF.OneCycleDuration;
        BehCtrl.RF.Limit = round(BehCtrl.Task.DelayTime/BehCtrl.RF.OneCycleDuration);    
        BehCtrl.tDontStartITI.StartDelay = BehCtrl.RF.OneCycleDuration;
    % update useless zone
    BehCtrl.Vizi.useless_left = 7;  %7 (10deg mode)
    BehCtrl.Vizi.useless_right = 4; %4
    BehCtrl.Vizi.useless_top = 3;   %3
    BehCtrl.Vizi.useless_bottom = 2;%2
    BehCtrl.Vizi.usefulMat = ones(18,32);
        BehCtrl.Vizi.usefulMat(:,[1:BehCtrl.Vizi.useless_left,end-BehCtrl.Vizi.useless_right+1:end]) = 0;
        BehCtrl.Vizi.usefulMat([1:BehCtrl.Vizi.useless_top,end-BehCtrl.Vizi.useless_bottom+1:end],:) = 0; 
        BehCtrl.Vizi.patchMat_x = BehCtrl.patchMat.patchMonitorMat_x .* BehCtrl.Vizi.usefulMat;
        BehCtrl.Vizi.patchMat_y = BehCtrl.patchMat.patchMonitorMat_y .* BehCtrl.Vizi.usefulMat;
    disp('RF Mode: SparseNoise_10deg')
end

function changeRoughRFRepeat(src,event)
global BehCtrl
BehCtrl.RoughMap.NumRepeat = str2double(get(BehCtrl.handles.roughRFMapRepeat,'String'));
str2double(get(BehCtrl.handles.roughRFMapRepeat,'String'))  % this is just to show the change in the command window
BehCtrl.tRoughRFMap.TasksToExecute = size(BehCtrl.Task.holePositionMat,1)*BehCtrl.RoughMap.NumRepeat;
disp('Repetition of Rough RF Mapping is updated')
end
function updateRoughRFType(src,event)
global BehCtrl
if src.Value == 1 % task stimuli
    BehCtrl.RoughMap.taskStim = 1;
    BehCtrl.tRoughRFMap.TasksToExecute = size(BehCtrl.Task.holePositionMat,1)*BehCtrl.RoughMap.NumRepeat;
    disp('Rough RF Mapping is done with task stimuli location')
elseif src.Value == 2 % full stimuli (15 stimuli)
    BehCtrl.RoughMap.taskStim = 2;  
    BehCtrl.tRoughRFMap.TasksToExecute = 15*BehCtrl.RoughMap.NumRepeat; 
    disp('Rough RF Mapping is done with full set of visual stimuli')
elseif src.Value == 3 % eight stimuli
    BehCtrl.RoughMap.taskStim = 3;  
    BehCtrl.tRoughRFMap.TasksToExecute = 8*BehCtrl.RoughMap.NumRepeat; 
    disp('Rough RF Mapping is done with 8 visual stimuli')    
end
end

%---- control for target directions



%---- grating speed setting

%---- stimulus selection callback

function visualizeTargetPosition(src,event)
global BehCtrl
% update the gui plot
    cla(BehCtrl.handles.manualAdjustTarget);
    axes(BehCtrl.handles.manualAdjustTarget);
    if BehCtrl.RF.degMode == 5
        plot(BehCtrl.handles.manualAdjustTarget,BehCtrl.Vizi.patchMat_x(:),BehCtrl.Vizi.patchMat_y(:),...
            'b.','MarkerSize',.2);
    elseif BehCtrl.RF.degMode == 10
        plot(BehCtrl.handles.manualAdjustTarget,BehCtrl.Vizi.patchMat_x(:),BehCtrl.Vizi.patchMat_y(:),...
            'r.','MarkerSize',.2);
    end
    set(BehCtrl.handles.manualAdjustTarget,'XLimMode','manual','XLim',[-700 700],'YLimMode','manual','YLim',[-680 680],...
        'xticklabel',[],'yticklabel',[]);
    hold on
    % display default position of target
    plot(BehCtrl.Sine.position_one(1) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Sine.position_one(2) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_one);
    plot(BehCtrl.Sine.position_two(1) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Sine.position_two(2) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_two);  
    plot(BehCtrl.Sine.position_three(1) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Sine.position_three(2) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_three); 
    plot(BehCtrl.Vizi.grating1(2) + 2*BehCtrl.Vizi.onepatchUnit_x*cos(-pi:0.01:pi),...
        BehCtrl.Vizi.grating1(3) + 2*BehCtrl.Vizi.onepatchUnit_y*sin(-pi:0.01:pi),...
        'Color',BehCtrl.Sine.color_bar);    
    
% update the enter box value
    set(BehCtrl.handles.enter_one_azimuth,'String',num2str(BehCtrl.Sine.position_one(1)));
    set(BehCtrl.handles.enter_two_azimuth,'String',num2str(BehCtrl.Sine.position_two(1)));
    set(BehCtrl.handles.enter_three_azimuth,'String',num2str(BehCtrl.Sine.position_three(1)));
    set(BehCtrl.handles.enter_bar_azimuth,'String',num2str(BehCtrl.Vizi.grating1(2)));    
    set(BehCtrl.handles.enter_one_altitude,'String',num2str(BehCtrl.Sine.position_one(2)));
    set(BehCtrl.handles.enter_two_altitude,'String',num2str(BehCtrl.Sine.position_two(2)));  
    set(BehCtrl.handles.enter_three_altitude,'String',num2str(BehCtrl.Sine.position_three(2)));
    set(BehCtrl.handles.enter_bar_altitude,'String',num2str(BehCtrl.Vizi.grating1(3))); 
% update the slider    
    set(BehCtrl.handles.slider_one_azimuth,'Value',BehCtrl.Sine.position_one(1));
    set(BehCtrl.handles.slider_two_azimuth,'Value',BehCtrl.Sine.position_two(1));
    set(BehCtrl.handles.slider_three_azimuth,'Value',BehCtrl.Sine.position_three(1));
    set(BehCtrl.handles.slider_bar_azimuth,'Value',BehCtrl.Vizi.grating1(2));    
    set(BehCtrl.handles.slider_one_altitude,'Value',BehCtrl.Sine.position_one(2));
    set(BehCtrl.handles.slider_two_altitude,'Value',BehCtrl.Sine.position_two(2));
    set(BehCtrl.handles.slider_three_altitude,'Value',BehCtrl.Sine.position_three(2));
    set(BehCtrl.handles.slider_bar_altitude,'Value',BehCtrl.Vizi.grating1(3));
end


function slide_one_azimuth(src,event)
global BehCtrl
BehCtrl.Sine.position_one(1) = BehCtrl.handles.slider_one_azimuth.Value;
BehCtrl.Vizi.sine_one(2) = BehCtrl.Sine.position_one(1);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function slide_two_azimuth(src,event)
global BehCtrl
BehCtrl.Sine.position_two(1) = BehCtrl.handles.slider_two_azimuth.Value;
BehCtrl.Vizi.sine_two(2) = BehCtrl.Sine.position_two(1);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function slide_three_azimuth(src,event)
global BehCtrl
BehCtrl.Sine.position_three(1) = BehCtrl.handles.slider_three_azimuth.Value;
BehCtrl.Vizi.sine_three(2) = BehCtrl.Sine.position_three(1);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function slide_bar_azimuth(src,event)
global BehCtrl
BehCtrl.Vizi.grating1(2) = BehCtrl.handles.slider_bar_azimuth.Value;
BehCtrl.Vizi.grating2(2) = BehCtrl.handles.slider_bar_azimuth.Value;
BehCtrl.Vizi.foreground(2) = BehCtrl.handles.slider_bar_azimuth.Value;

BehCtrl.Task.currentShiftingTarget_bar = [BehCtrl.Vizi.grating1(2),BehCtrl.Vizi.grating1(3)];

updateStimMat;
visualizeTargetPosition;
end

function slide_one_altitude(src,event)
global BehCtrl
BehCtrl.Sine.position_one(2) = BehCtrl.handles.slider_one_altitude.Value;
BehCtrl.Vizi.sine_one(3) = BehCtrl.Sine.position_one(2);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function slide_two_altitude(src,event)
global BehCtrl
BehCtrl.Sine.position_two(2) = BehCtrl.handles.slider_two_altitude.Value;
BehCtrl.Vizi.sine_two(3) = BehCtrl.Sine.position_two(2);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function slide_three_altitude(src,event)
global BehCtrl
BehCtrl.Sine.position_three(2) = BehCtrl.handles.slider_three_altitude.Value;
BehCtrl.Vizi.sine_three(3) = BehCtrl.Sine.position_three(2);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function slide_bar_altitude(src,event)
global BehCtrl
BehCtrl.Vizi.grating1(3) = BehCtrl.handles.slider_bar_altitude.Value;
BehCtrl.Vizi.grating2(3) = BehCtrl.handles.slider_bar_altitude.Value;
BehCtrl.Vizi.foreground(3) = BehCtrl.handles.slider_bar_altitude.Value;

BehCtrl.Task.currentShiftingTarget_bar = [BehCtrl.Vizi.grating1(2),BehCtrl.Vizi.grating1(3)];

updateStimMat;
visualizeTargetPosition;
end

function updateEnter_one_azimuth(src,event)
global BehCtrl
BehCtrl.Sine.position_one(1) = str2double(get(BehCtrl.handles.enter_one_azimuth,'String'));
BehCtrl.Vizi.sine_one(2) = BehCtrl.Sine.position_one(1);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function updateEnter_two_azimuth(src,event)
global BehCtrl
BehCtrl.Sine.position_two(1) = str2double(get(BehCtrl.handles.enter_two_azimuth,'String'));
BehCtrl.Vizi.sine_two(2) = BehCtrl.Sine.position_two(1);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function updateEnter_three_azimuth(src,event)
global BehCtrl
BehCtrl.Sine.position_three(1) = str2double(get(BehCtrl.handles.enter_three_azimuth,'String'));
BehCtrl.Vizi.sine_three(2) = BehCtrl.Sine.position_three(1);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function updateEnter_bar_azimuth(src,event)
global BehCtrl
BehCtrl.Vizi.grating1(2) = str2double(get(BehCtrl.handles.enter_bar_azimuth,'String'));
BehCtrl.Vizi.grating2(2) = str2double(get(BehCtrl.handles.enter_bar_azimuth,'String'));
BehCtrl.Vizi.foreground(2) = str2double(get(BehCtrl.handles.enter_bar_azimuth,'String'));

BehCtrl.Task.currentShiftingTarget_bar = [BehCtrl.Vizi.grating1(2),BehCtrl.Vizi.grating1(3)];

updateStimMat;
visualizeTargetPosition;
end

function updateEnter_one_altitude(src,event)
global BehCtrl
BehCtrl.Sine.position_one(2) = str2double(get(BehCtrl.handles.enter_one_altitude,'String'));
BehCtrl.Vizi.sine_one(3) = BehCtrl.Sine.position_one(2);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function updateEnter_two_altitude(src,event)
global BehCtrl
BehCtrl.Sine.position_two(2) = str2double(get(BehCtrl.handles.enter_two_altitude,'String'));
BehCtrl.Vizi.sine_two(3) = BehCtrl.Sine.position_two(2);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function updateEnter_three_altitude(src,event)
global BehCtrl
BehCtrl.Sine.position_three(2) = str2double(get(BehCtrl.handles.enter_three_altitude,'String'));
BehCtrl.Vizi.sine_three(3) = BehCtrl.Sine.position_three(2);
updateStimMat;
updateHolePosition;
visualizeTargetPosition;
end
function updateEnter_bar_altitude(src,event)
global BehCtrl
BehCtrl.Vizi.grating1(3) = str2double(get(BehCtrl.handles.enter_bar_altitude,'String'));
BehCtrl.Vizi.grating2(3) = str2double(get(BehCtrl.handles.enter_bar_altitude,'String'));
BehCtrl.Vizi.foreground(3) = str2double(get(BehCtrl.handles.enter_bar_altitude,'String'));

BehCtrl.Task.currentShiftingTarget_bar = [BehCtrl.Vizi.grating1(2),BehCtrl.Vizi.grating1(3)];

updateStimMat;
visualizeTargetPosition;
end

function slideHoleSize(src,event)
global BehCtrl
BehCtrl.Bar.holeSize = BehCtrl.handles.slider_holeSize.Value;
BehCtrl.LSNStimMat(:,26) = BehCtrl.Bar.holeSize; 
% update a task vector for "BehCtrl.RF.Mapping == false" mode (no sparse
% noises shown)
BehCtrl.Vizi.targetWOsparsenoise = BehCtrl.LSNStimMat(1,:);
BehCtrl.Vizi.targetWOsparsenoise(36:6:156) = 12;
% update indicator
set(BehCtrl.handles.enterholeSize,'String',num2str(BehCtrl.Bar.holeSize));
end
function updateHoleSize(src,event)
global BehCtrl
BehCtrl.Bar.holeSize = str2double(get(BehCtrl.handles.enterholeSize,'String'));
BehCtrl.LSNStimMat(:,26) = BehCtrl.Bar.holeSize; 
% update slider
set(BehCtrl.handles.slider_holeSize,'Value',BehCtrl.Bar.holeSize);
end
%---------------- end of stim selection callback
%---------------- callback of gray period length    
function updateGrayDuration_Min(src,event)
global BehCtrl
BehCtrl.Task.grayDuration.Min = str2double(get(BehCtrl.handles.grayDuration.Min,'String'));
end

function updateGrayDuration_Mean(src,event)
global BehCtrl
BehCtrl.Task.grayDuration.Mean = str2double(get(BehCtrl.handles.grayDuration.Mean,'String'));
end

function updateGrayDuration_Max(src,event)
global BehCtrl
BehCtrl.Task.grayDuration.Max = str2double(get(BehCtrl.handles.grayDuration.Max,'String'));
end
%---------------- end of callback of gray period length
%---------------- subfunctions for Go/NoGo Task
function changeRFStimDuration(src,event)
global BehCtrl
BehCtrl.RF.OneCycleDuration = str2double(get(BehCtrl.handles.RFStimDuration,'String'));
str2double(get(BehCtrl.handles.RFStimDuration,'String'))  % this is just to show the change in the command window
BehCtrl.tRFMap.Period = BehCtrl.RF.OneCycleDuration;
BehCtrl.tTaskStim.Period = BehCtrl.RF.OneCycleDuration;
BehCtrl.tDontStartITI.StartDelay = BehCtrl.RF.OneCycleDuration;
BehCtrl.Task.numCycleDist = round(BehCtrl.Task.durationDist./BehCtrl.RF.OneCycleDuration);
disp('RF Stim Duration updated')
end

function changeFileNumber(src,event)
global BehCtrl
BehCtrl.RF.fileNumber = str2double(get(BehCtrl.handles.fileNumber,'String'));
str2double(get(BehCtrl.handles.fileNumber,'String'))  % this is just to show the change in the command window
% update order vectors
BehCtrl.LSNStimMat = BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(:,:,BehCtrl.RF.fileNumber);
end
function changelickthreshold(src,event)
global BehCtrl
BehCtrl.Task.LickThresh = str2double(get(BehCtrl.handles.LickThresh,'String'));
str2double(get(BehCtrl.handles.LickThresh,'String'))
end
function changeRunSpeedthreshold(src,event)
global BehCtrl
BehCtrl.Task.SpeedThresh = str2double(get(BehCtrl.handles.RunSpeedThresh,'String'));
str2double(get(BehCtrl.handles.RunSpeedThresh,'String'))
end
function changeSessionTimeValue(src,event)
global BehCtrl
BehCtrl.Task.sessionTime = str2double(get(BehCtrl.handles.sessionTimeValue,'String'));
str2double(get(BehCtrl.handles.sessionTimeValue,'String'))
end
function changeITIduration(src,event)
global BehCtrl
BehCtrl.Task.ITIduration = str2double(get(BehCtrl.handles.ITIduration,'String'));
str2double(get(BehCtrl.handles.ITIduration,'String'))
% update ITI duration
BehCtrl.tEnd.StartDelay = BehCtrl.Task.ITIduration;
end
function changeGracePeriod(src,event)
global BehCtrl
BehCtrl.Task.GracePeriod = str2double(get(BehCtrl.handles.GracePeriod,'String'));
str2double(get(BehCtrl.handles.GracePeriod,'String'))
% update grace period duration
BehCtrl.tlicklistener_Rew.StartDelay = BehCtrl.Task.GracePeriod;
BehCtrl.tlicklistener_Puff.StartDelay = BehCtrl.Task.GracePeriod;
% update automatic reward delay
BehCtrl.tAutoRew.StartDelay = BehCtrl.Task.AutoRewDelay + BehCtrl.Task.GracePeriod;

end
function changeGoprob(src,event)
global BehCtrl
BehCtrl.Task.Goprob = str2double(get(BehCtrl.handles.Goprob,'String'));
BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.Goprob; 
set(BehCtrl.handles.currentGoProb,'String',num2str(BehCtrl.Task.GoprobOnGoing));
disp('On going Go probability reset')
end
function changeCatchprob(src,event)
global BehCtrl
BehCtrl.Task.Catchprob = str2double(get(BehCtrl.handles.Catchprob,'String'));
if strcmp(BehCtrl.Task.numPatchMode,'1_patch') && BehCtrl.Task.Catchprob > 0
    warning('1_patch mode should not have catch trials (probability is set to zero)');
    BehCtrl.Task.Catchprob = 0;
    set(BehCtrl.handles.Catchprob,'String',num2str(BehCtrl.Task.Catchprob));
end
end

function changeNumHitsBeforecatch(src,event)
global BehCtrl
BehCtrl.Task.numHitsBeforecatch = str2double(get(BehCtrl.handles.numHitsBeforecatch,'String'));
if strcmp(BehCtrl.Task.numPatchMode,'1_patch') 
    warning('1_patch mode should not have catch trials (change is aborted)');
    BehCtrl.Task.numHitsBeforecatch = 10000;
    set(BehCtrl.handles.numHitsBeforecatch,'String',num2str(BehCtrl.Task.numHitsBeforecatch));
end
end
%==== related to block structure
function activateBlock(src,event)
global BehCtrl
if BehCtrl.handles.activateBlock.Value == 1
    BehCtrl.Task.BlockActivated = true;
    % set up block counter
    BehCtrl.Task.blockCount = 1;
    % start counting trials
    BehCtrl.Task.blockTrialCount = 0;
    % gui appearance
    set(BehCtrl.handles.activateBlock,'String','Block activated','BackgroundColor',[0 0.8 0],'ForegroundColor','black');
    set(BehCtrl.handles.blockTrialCounter,'String',num2str(BehCtrl.Task.blockTrialCount));
else
    BehCtrl.Task.BlockActivated = false;
    % set up block counter
    BehCtrl.Task.blockCount = NaN;
    % start counting trials
    BehCtrl.Task.blockTrialCount = NaN;    
    % gui appearance
    set(BehCtrl.handles.activateBlock,'String','activate Block?','BackgroundColor',[1,0.4,0.15]);
    set(BehCtrl.handles.blockTrialCounter,'String',num2str(BehCtrl.Task.blockTrialCount));
end
end
function changeBlockSize(src,event)
global BehCtrl
BehCtrl.Task.blockSize = str2double(get(BehCtrl.handles.blockSize,'String'));
end
function changeNumBlocks(src,event)
global BehCtrl
BehCtrl.Task.numBlocks = str2double(get(BehCtrl.handles.numBlocks,'String'));
end

%====
function changeValveDuration(src,event)
global BehCtrl
BehCtrl.Task.ValveDuration = str2double(get(BehCtrl.handles.ValveDuration,'String'));
end
function changeAirValveDuration(src,event)
global BehCtrl
BehCtrl.Task.AirValveDuration = str2double(get(BehCtrl.handles.AirValveDuration,'String'));
end
function giveDelayBeforeValveOpens(event,src)
global BehCtrl
switch BehCtrl.handles.ifValveOpensWithDelay.Value
    case 0 % button not pressed
    % make the condition true
    BehCtrl.Task.ifValveOpensWithDelay = 1;
    % update gui appearance
    set(BehCtrl.handles.ifValveOpensWithDelay,'String','w/ delay',...
        'BackgroundColor',[0,0.8,0],'ForegroundColor','white',...
        'FontWeight','bold');
    % make the fields activated    
    set(BehCtrl.handles.ValveDelay_mean,'enable','on');
    set(BehCtrl.handles.ValveDelay_sd,'enable','on');
    set(BehCtrl.handles.ValveDelay_min,'enable','on');
    set(BehCtrl.handles.ValveDelay_max,'enable','on');
    case 1  % button pressed
    % make the condition false
    BehCtrl.Task.ifValveOpensWithDelay = 0;
    % update gui appearance
    set(BehCtrl.handles.ifValveOpensWithDelay,'String','w/o delay',...
        'BackgroundColor',[0.4,0.4,0.5],'ForegroundColor','white',...
        'FontWeight','bold');
    % make the fields inactivated
    set(BehCtrl.handles.ValveDelay_mean,'Enable','inactive');
    set(BehCtrl.handles.ValveDelay_sd,'Enable','inactive');
    set(BehCtrl.handles.ValveDelay_min,'Enable','inactive');
    set(BehCtrl.handles.ValveDelay_max,'Enable','inactive');    
end

end
function changeValveDelay_mean(src,event)
global BehCtrl
BehCtrl.Task.delayMean = str2double(get(BehCtrl.handles.ValveDelay_mean,'String'));
% update the distribution
BehCtrl.Task.delayDistribution = truncate(makedist('Normal','mu',BehCtrl.Task.delayMean,'sigma',BehCtrl.Task.delaySD),BehCtrl.Task.delayMin,BehCtrl.Task.delayMax);
end
function changeValveDelay_sd(src,event)
global BehCtrl
BehCtrl.Task.delaySD = str2double(get(BehCtrl.handles.ValveDelay_sd,'String'));
% update the distribution
BehCtrl.Task.delayDistribution = truncate(makedist('Normal','mu',BehCtrl.Task.delayMean,'sigma',BehCtrl.Task.delaySD),BehCtrl.Task.delayMin,BehCtrl.Task.delayMax);
end
function changeValveDelay_min(src,event)
global BehCtrl
BehCtrl.Task.delayMin = str2double(get(BehCtrl.handles.ValveDelay_min,'String'));
% update the distribution
BehCtrl.Task.delayDistribution = truncate(makedist('Normal','mu',BehCtrl.Task.delayMean,'sigma',BehCtrl.Task.delaySD),BehCtrl.Task.delayMin,BehCtrl.Task.delayMax);
end
function changeValveDelay_max(src,event)
global BehCtrl
BehCtrl.Task.delayMax = str2double(get(BehCtrl.handles.ValveDelay_max,'String'));
% update the distribution
BehCtrl.Task.delayDistribution = truncate(makedist('Normal','mu',BehCtrl.Task.delayMean,'sigma',BehCtrl.Task.delaySD),BehCtrl.Task.delayMin,BehCtrl.Task.delayMax);
end
function changeStimDuration(src,event)
global BehCtrl
BehCtrl.Task.StimDuration = str2double(get(BehCtrl.handles.stimDuration,'String'));
BehCtrl.tITIcountDown.StartDelay = BehCtrl.Task.StimDuration;
BehCtrl.tTaskStim.TasksToExecute = ceil(BehCtrl.Task.StimDuration/BehCtrl.tTaskStim.Period);
BehCtrl.Task.durationDist = BehCtrl.Task.StimDuration;
set(BehCtrl.handles.durationDist,'String',num2str(BehCtrl.Task.durationDist));
BehCtrl.Task.numCycleDist = round(BehCtrl.Task.durationDist./BehCtrl.RF.OneCycleDuration);
end
function changeAutoRewDur(~,event)
global BehCtrl
BehCtrl.Task.AutoRewDelay = str2double(get(BehCtrl.handles.AutoRewDelay,'String'));
BehCtrl.tAutoRew.StartDelay = BehCtrl.Task.AutoRewDelay + BehCtrl.Task.GracePeriod;
disp('auto rew delay is updated')
end
function changeAutoRewValveDuration(src,event)
global BehCtrl
BehCtrl.Task.AutoRewValveDuration = str2double(get(BehCtrl.handles.AutoRewValveDuration,'String'));
end
function singleLickShot(src,event)
global BehCtrl
    triggerMouseLicked(BehCtrl.CurrState)
    % change indicator color
    set(BehCtrl.handles.sensorState,'BackgroundColor',[0.5,0.5,0.5]);
    pause(0.1)
    set(BehCtrl.handles.sensorState,'BackgroundColor',[1,0.4,0.15]);
end
function lickIndicatorColor(src,event)
global BehCtrl
if BehCtrl.Task.lickIndicatorFlag == 0
    start(BehCtrl.tLickIndicatorColor);
    BehCtrl.Task.lickIndicatorFlag = 1;
end
end
function LickIndicatorColorBackToDark(src,event)
global BehCtrl
set(BehCtrl.handles.lickIndicator,'BackgroundColor',[0,0.25,0]);
BehCtrl.Task.lickIndicatorFlag = 0;
end
function updateTaskCounter(src,event)
global BehCtrl
BehCtrl.taskCounter.toc = round(toc(BehCtrl.Task.tic),2);
set(BehCtrl.handles.taskCounter,'String',sprintf('%4.2f', BehCtrl.taskCounter.toc));
%drawnow
end
function updateTimerFirst(src,event)
global BehCtrl
BehCtrl.timerFirst.toc = round(datevec(toc(BehCtrl.timerFirst.tic)./(60*60*24)));
set(BehCtrl.handles.timerFirst,'String',...
    sprintf('%s:%s:%s', num2str(BehCtrl.timerFirst.toc(4)),num2str(BehCtrl.timerFirst.toc(5)),num2str(BehCtrl.timerFirst.toc(6))));
%drawnow
end
function clearTimerFirst(src,event)
global BehCtrl
BehCtrl.timerFirst.tic = tic;
stop(BehCtrl.tTimerFirst);
start(BehCtrl.tTimerFirst);
end
function updateTimerSecond(src,event)
global BehCtrl
if toc(BehCtrl.timerSecond.tic) > BehCtrl.Task.sessionTime * 60
    BehCtrl.timeIsOver = true;
end
BehCtrl.timerSecond.toc = round(datevec(toc(BehCtrl.timerSecond.tic)./(60*60*24)));
set(BehCtrl.handles.timerSecond,'String',...
    sprintf('%s:%s:%s', num2str(BehCtrl.timerSecond.toc(4)),num2str(BehCtrl.timerSecond.toc(5)),num2str(BehCtrl.timerSecond.toc(6))));
%drawnow
end
function clearTimerSecond(src,event)
global BehCtrl
BehCtrl.timerSecond.tic = tic;
stop(BehCtrl.tTimerSecond);
start(BehCtrl.tTimerSecond);
end



function updateARSetting(src,event)
global BehCtrl
if BehCtrl.handles.ifGiveAR.Value == 1
    BehCtrl.Task.AutoRew = false;
    set(BehCtrl.handles.ifGiveAR,'String','AutoRew is blocked...','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor','white');
else
    BehCtrl.Task.AutoRew = true;
    set(BehCtrl.handles.ifGiveAR,'String','Stop Auto Reward?','BackgroundColor',[1,0.4,0.15]);        
end
end
function showSNonTarget(src,event)
global BehCtrl
if BehCtrl.handles.showSNonTarget.Value == 1 % when button is pressed
    BehCtrl.Task.showSNonTarget = true;% false by default
    set(BehCtrl.handles.showSNonTarget,'String','SN shown on Target','BackgroundColor',[0 0.8 0],'ForegroundColor','black');
else
    BehCtrl.Task.showSNonTarget = false;
    set(BehCtrl.handles.showSNonTarget,'String','Show SN on Target?','BackgroundColor',[1,0.4,0.15]);        
end
end
function updatePuffSetting(src,event)
global BehCtrl
if BehCtrl.handles.ifPuffOnFA.Value == 1
    BehCtrl.Task.PuffOnFA = false;
    set(BehCtrl.handles.ifPuffOnFA,'String','AirPuff is blocked...','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor','white');
else
    BehCtrl.Task.PuffOnFA = true;
    set(BehCtrl.handles.ifPuffOnFA,'String','Stop Puff on FA?','BackgroundColor',[1,0.4,0.15]);        
end
end
function updateEarlyLickSetting(src,event)
global BehCtrl
if BehCtrl.handles.ifResetAfterEL.Value == 1
    BehCtrl.Task.earlyLickResetTrial = false;
    set(BehCtrl.handles.ifResetAfterEL,'String','No reset after EL...','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor','white');
else
    BehCtrl.Task.earlyLickResetTrial = true;
    set(BehCtrl.handles.ifResetAfterEL,'String','Stop Reseting on EL?','BackgroundColor',[1,0.4,0.15]);        
end
end
function runningTriggerTrials(src,event)
global BehCtrl
if BehCtrl.handles.ifTriggerByRun.Value == 1
    BehCtrl.Task.runningTriggerTrials = true;
    set(BehCtrl.handles.ifTriggerByRun,'String','Run is triggering...','BackgroundColor',[0 0.8 0]);
else
    BehCtrl.Task.runningTriggerTrials = false;
    set(BehCtrl.handles.ifTriggerByRun,'String','Running Trigger Trial?','BackgroundColor',[1,0.4,0.15]); 
           
end
end
function sessionHAStimeLimit(src,event)
global BehCtrl
if BehCtrl.handles.sessionTimeLimit.Value == 1  % button pressed
    BehCtrl.Task.sessionHAStimeLimit = false;
    set(BehCtrl.handles.sessionTimeLimit,'String','Time Limit OFF..','BackgroundColor',[0.3 0.3 0.3]);
else
    BehCtrl.Task.sessionHAStimeLimit = true;
    set(BehCtrl.handles.sessionTimeLimit,'String','Time Limit ON!','BackgroundColor',[1,0.4,0.15]); 
end
end
function updateRewardSetting(src,event)
global BehCtrl
if BehCtrl.handles.ifStopValveOpening.Value == 1
    BehCtrl.Task.ifBlockLFRreward = true;
    set(BehCtrl.handles.ifStopValveOpening,'String','No LFR reward...','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor','white');
else
    BehCtrl.Task.ifBlockLFRreward = false;
    set(BehCtrl.handles.ifStopValveOpening,'String','Stop LFR reward?','BackgroundColor',[1,0.4,0.15]);        
end
end


function shuffleFileNumber(src,event)
global BehCtrl
    BehCtrl.RF.fileNumber = randsample(10,1);
    set(BehCtrl.handles.fileNumber,'String',num2str(BehCtrl.RF.fileNumber));
    % update order vectors
    BehCtrl.LSNStimMat = BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(:,:,BehCtrl.RF.fileNumber);

end
function openAndclosePuffValve(event,src)
global BehCtrl
    outputSingleScan(BehCtrl.Digsess,[0,1])% open puff valve
    disp('air valve opened')
    BehCtrl.tAirValveClose.StartDelay = BehCtrl.Task.AirValveDuration;
    start(BehCtrl.tAirValveClose) % start timer for closing valve  
end
function openAndcloseRewardValve(event,src)
global BehCtrl
    outputSingleScan(BehCtrl.Digsess,[1,0])
    disp('valve opened')
    BehCtrl.tValveClose.StartDelay = BehCtrl.Task.ValveDuration;
    start(BehCtrl.tValveClose)
end
function tAirValveCloseStopFcn(src,event)
global BehCtrl
BehCtrl.Task.PuffFlag=0;
set(BehCtrl.handles.Puff, 'BackgroundColor','black');
end
function edgeSharpOrGraded(src,event)
global BehCtrl
if BehCtrl.handles.foreground.Value == 1 % if the button is pressed: sharp edge for grating patches
    BehCtrl.LSNStimMat(:,21) = 20; 
    BehCtrl.Vizi.FG1 = 20;
    BehCtrl.Vizi.GrayWithoutPD(21) = 20;
    BehCtrl.Vizi.GrayWithPD(21) = 20;
    set(BehCtrl.handles.FG1,'String',sprintf('%s',num2str(BehCtrl.Vizi.FG1)),'ForegroundColor','red');
    set(BehCtrl.handles.foreground,'String','Sharp','ForegroundColor','red');
else
    BehCtrl.LSNStimMat(:,21) = 30;  
    BehCtrl.Vizi.FG1 = 30;
    BehCtrl.Vizi.GrayWithoutPD(21) = 30;
    BehCtrl.Vizi.GrayWithPD(21) = 30;
    set(BehCtrl.handles.FG1,'String',sprintf('%s',num2str(BehCtrl.Vizi.FG1)),'ForegroundColor','blue');
    set(BehCtrl.handles.foreground,'String','Graded','ForegroundColor','blue'); 
end
end
function photodiodePatchOnOff(src,event)
global BehCtrl
if BehCtrl.handles.photodiode.Value == 1 % if the button is pressed: photodiode patch is OFF
    BehCtrl.LSNStimMat(:,32) = 0; 
    BehCtrl.Vizi.PD6 = 0;
    BehCtrl.Vizi.GrayWithPD(32) = 0;
    set(BehCtrl.handles.PD6,'String',sprintf('%s',num2str(BehCtrl.Vizi.PD6)));
    set(BehCtrl.handles.photodiode,'String','OFF','ForegroundColor','black');
else
    BehCtrl.LSNStimMat(:,32) = BehCtrl.photodiodePatchSize;  
    BehCtrl.Vizi.PD6 = BehCtrl.photodiodePatchSize;
    BehCtrl.Vizi.GrayWithPD(32) = BehCtrl.photodiodePatchSize;
    set(BehCtrl.handles.PD6,'String',sprintf('%s',num2str(BehCtrl.Vizi.PD6)));
    set(BehCtrl.handles.photodiode,'String','PD','ForegroundColor','white'); 
end
end

function convertPxlToVizivalueX(src,event)
global BehCtrl
BehCtrl.Vizi.pixelX = str2double(get(BehCtrl.handles.pixelX,'String'));
BehCtrl.Vizi.LSN2 = BehCtrl.LSNvectorLibrary.patchMonitorMat(BehCtrl.Vizi.pixelY,BehCtrl.Vizi.pixelX,1);
set(BehCtrl.handles.LSN2,'String',sprintf('%s',num2str(BehCtrl.Vizi.LSN2)))
end
function convertPxlToVizivalueY(src,event)
global BehCtrl
BehCtrl.Vizi.pixelY = str2double(get(BehCtrl.handles.pixelY,'String'));
BehCtrl.Vizi.LSN3 = BehCtrl.LSNvectorLibrary.patchMonitorMat(BehCtrl.Vizi.pixelY,BehCtrl.Vizi.pixelX,2);
set(BehCtrl.handles.LSN3,'String',sprintf('%s',num2str(BehCtrl.Vizi.LSN3)))
end
%%----manually update Vizi vector

function sendAndSetViziVector(src,event)
global BehCtrl
BehCtrl.Vizi.BG1 = str2double(get(BehCtrl.handles.BG1,'String'));
BehCtrl.Vizi.BG2 = str2double(get(BehCtrl.handles.BG2,'String'));
BehCtrl.Vizi.BG3 = str2double(get(BehCtrl.handles.BG3,'String'));
BehCtrl.Vizi.BG4 = str2double(get(BehCtrl.handles.BG4,'String'));
BehCtrl.Vizi.BG5 = str2double(get(BehCtrl.handles.BG5,'String'));
BehCtrl.Vizi.BG6 = str2double(get(BehCtrl.handles.BG6,'String'));
BehCtrl.Vizi.GRone1 = str2double(get(BehCtrl.handles.GRone1,'String'));
BehCtrl.Vizi.GRone2 = str2double(get(BehCtrl.handles.GRone2,'String'));
BehCtrl.Vizi.GRone3 = str2double(get(BehCtrl.handles.GRone3,'String'));
BehCtrl.Vizi.GRone4 = str2double(get(BehCtrl.handles.GRone4,'String'));
BehCtrl.Vizi.GRone5 = str2double(get(BehCtrl.handles.GRone5,'String'));
BehCtrl.Vizi.GRone6 = str2double(get(BehCtrl.handles.GRone6,'String'));
BehCtrl.Vizi.GRtwo1 = str2double(get(BehCtrl.handles.GRtwo1,'String'));
BehCtrl.Vizi.GRtwo2 = str2double(get(BehCtrl.handles.GRtwo2,'String'));
BehCtrl.Vizi.GRtwo3 = str2double(get(BehCtrl.handles.GRtwo3,'String'));
BehCtrl.Vizi.GRtwo4 = str2double(get(BehCtrl.handles.GRtwo4,'String'));
BehCtrl.Vizi.GRtwo5 = str2double(get(BehCtrl.handles.GRtwo5,'String'));
BehCtrl.Vizi.GRtwo6 = str2double(get(BehCtrl.handles.GRtwo6,'String'));
BehCtrl.Vizi.FG1 = str2double(get(BehCtrl.handles.FG1,'String'));
BehCtrl.Vizi.FG2 = str2double(get(BehCtrl.handles.FG2,'String'));
BehCtrl.Vizi.FG3 = str2double(get(BehCtrl.handles.FG3,'String'));
BehCtrl.Vizi.FG4 = str2double(get(BehCtrl.handles.FG4,'String'));
BehCtrl.Vizi.FG5 = str2double(get(BehCtrl.handles.FG5,'String'));
BehCtrl.Vizi.FG6 = str2double(get(BehCtrl.handles.FG6,'String'));
BehCtrl.Vizi.PD1 = str2double(get(BehCtrl.handles.PD1,'String'));
BehCtrl.Vizi.PD2 = str2double(get(BehCtrl.handles.PD2,'String'));
BehCtrl.Vizi.PD3 = str2double(get(BehCtrl.handles.PD3,'String'));
BehCtrl.Vizi.PD4 = str2double(get(BehCtrl.handles.PD4,'String'));
BehCtrl.Vizi.PD5 = str2double(get(BehCtrl.handles.PD5,'String'));
BehCtrl.Vizi.PD6 = str2double(get(BehCtrl.handles.PD6,'String'));
BehCtrl.Vizi.LSN1 = str2double(get(BehCtrl.handles.LSN1,'String'));
BehCtrl.Vizi.LSN2 = str2double(get(BehCtrl.handles.LSN2,'String'));
BehCtrl.Vizi.LSN3 = str2double(get(BehCtrl.handles.LSN3,'String'));
BehCtrl.Vizi.LSN4 = str2double(get(BehCtrl.handles.LSN4,'String'));
BehCtrl.Vizi.LSN5 = str2double(get(BehCtrl.handles.LSN5,'String'));
BehCtrl.Vizi.LSN6 = str2double(get(BehCtrl.handles.LSN6,'String'));
BehCtrl.Vizi.sine1 = str2double(get(BehCtrl.handles.sinePatch1,'String'));
BehCtrl.Vizi.sine2 = str2double(get(BehCtrl.handles.sinePatch2,'String'));
BehCtrl.Vizi.sine3 = str2double(get(BehCtrl.handles.sinePatch3,'String'));
BehCtrl.Vizi.sine4 = str2double(get(BehCtrl.handles.sinePatch4,'String'));
BehCtrl.Vizi.sine5 = str2double(get(BehCtrl.handles.sinePatch5,'String'));
BehCtrl.Vizi.sine6 = str2double(get(BehCtrl.handles.sinePatch6,'String'));
BehCtrl.Vizi.sine7 = str2double(get(BehCtrl.handles.sinePatch7,'String'));

BehCtrl.Vizi.background = [BehCtrl.Vizi.BG1,...
                               BehCtrl.Vizi.BG2,...
                               BehCtrl.Vizi.BG3,...
                               BehCtrl.Vizi.BG4,...
                               BehCtrl.Vizi.BG5,...
                               BehCtrl.Vizi.BG6];
BehCtrl.Vizi.grating1 = [BehCtrl.Vizi.GRone1,...
                               BehCtrl.Vizi.GRone2,...
                               BehCtrl.Vizi.GRone3,...
                               BehCtrl.Vizi.GRone4,...
                               BehCtrl.Vizi.GRone5,...
                               BehCtrl.Vizi.GRone6];
BehCtrl.Vizi.grating2 = [BehCtrl.Vizi.GRtwo1,...
                               BehCtrl.Vizi.GRtwo2,...
                               BehCtrl.Vizi.GRtwo3,...
                               BehCtrl.Vizi.GRtwo4,...
                               BehCtrl.Vizi.GRtwo5,...
                               BehCtrl.Vizi.GRtwo6];                         
BehCtrl.Vizi.foreground = [BehCtrl.Vizi.FG1,...
                               BehCtrl.Vizi.FG2,...
                               BehCtrl.Vizi.FG3,...
                               BehCtrl.Vizi.FG4,...
                               BehCtrl.Vizi.FG5,...
                               BehCtrl.Vizi.FG6];
BehCtrl.Vizi.photodiode = [BehCtrl.Vizi.PD1,...
                               BehCtrl.Vizi.PD2,...
                               BehCtrl.Vizi.PD3,...
                               BehCtrl.Vizi.PD4,...
                               BehCtrl.Vizi.PD5,...
                               BehCtrl.Vizi.PD6];
BehCtrl.Vizi.LSNpatch1 = [BehCtrl.Vizi.LSN1,...
                               BehCtrl.Vizi.LSN2,...
                               BehCtrl.Vizi.LSN3,...
                               BehCtrl.Vizi.LSN4,...
                               BehCtrl.Vizi.LSN5,...
                               BehCtrl.Vizi.LSN6]; 
                           
BehCtrl.Vizi.sinePatch = [BehCtrl.Vizi.sine1,...
                               BehCtrl.Vizi.sine2,...
                               BehCtrl.Vizi.sine3,...
                               BehCtrl.Vizi.sine4,...
                               BehCtrl.Vizi.sine5,...
                               BehCtrl.Vizi.sine6,...
                               BehCtrl.Vizi.sine7];                            
                           
BehCtrl.Vizi.vectorToSend = cat(2,[0 0],...
                                 BehCtrl.Vizi.background,...
                                 BehCtrl.Vizi.grating1,...
                                 BehCtrl.Vizi.grating2,...
                                 BehCtrl.Vizi.foreground,...
                                 BehCtrl.Vizi.photodiode,...
                                 BehCtrl.Vizi.LSNpatch1,...
                                 zeros(1,6*20),...
                                 BehCtrl.Vizi.sinePatch,...
                                 zeros(1,7*4));
% show it on the monitor
 convertAndsendVizivector(BehCtrl.Vizi.vectorToSend);

end


% subfunction for sending sparse noise overlapping with target to
% background
function TaskViziVectorSent = sendItBack(TaskViziVector,holePositionMat)
% [INPUTs]
%  - TaskViziVector:
%    a vizi vector that is sent as a TASK stimulus
%    ex) BehCtrl.Vizi.TaskVectorToSend
%  - holePositionMat
%    a matrix that concatenated all target positions in the 1st dimention
%    ex) if 3 patch mode...
%      BehCtrl.Sine.position_one = [350,200];
%      BehCtrl.Sine.position_two = [150,-200];
%      BehCtrl.Sine.position_three = [-50,200];
%      BehCtrl.Task.holePositionMat = ...
%           cat(1,BehCtrl.Sine.position_one,BehCtrl.Sine.position_two,BehCtrl.Sine.position_three);
global BehCtrl
% extract sparse noise part and reshape it
sparseNoise = permute(reshape(TaskViziVector(33:158),6,[]),[2,1]);
for I = 1:size(holePositionMat,1)
    position_x = holePositionMat(I,1);
    position_y = holePositionMat(I,2);
    % '4*' will not be a good number if the size of sine patch is changed
    avoidZone_x = [position_x-4*BehCtrl.Vizi.onepatchUnit_x, position_x+4*BehCtrl.Vizi.onepatchUnit_x];
    avoidZone_y = [position_y-4*BehCtrl.Vizi.onepatchUnit_y, position_y+4*BehCtrl.Vizi.onepatchUnit_y];

    for i = 1:21 % for all sparse noise sheets
        if sparseNoise(i,2) > avoidZone_x(1) && sparseNoise(i,2) < avoidZone_x(2) &&...
                sparseNoise(i,3) > avoidZone_y(1) && sparseNoise(i,3) < avoidZone_y(2)
            sparseNoise(i,4) = 10; % send it to back
        end
    end
end
TaskViziVectorSent = cat(2,TaskViziVector(1:32),reshape(permute(sparseNoise,[2,1]),1,[]),TaskViziVector(159:end));
end

% [ONLY for 10 deg mode] subfunction for sending back sparse noises next to the
% one that is already sent back
function TaskViziVectorWithNeighborsSent = sendNeighborsBack(TaskViziVectorSent)
global BehCtrl
% extract sparse noise part and reshape it
sparseNoise = permute(reshape(TaskViziVectorSent(33:158),6,[]),[2,1]);
for i = 1:21
    if sparseNoise(i,4) == 10
        x_coordinate = sparseNoise(i,2);
        y_coordinate = sparseNoise(i,3);
        for ii = 1:21
            if sparseNoise(ii,2) > x_coordinate - BehCtrl.Vizi.onepatchUnit_x &&...
                    sparseNoise(ii,2) < x_coordinate + BehCtrl.Vizi.onepatchUnit_x &&...
                    sparseNoise(ii,3) > y_coordinate - BehCtrl.Vizi.onepatchUnit_y &&...
                    sparseNoise(ii,3) < y_coordinate + BehCtrl.Vizi.onepatchUnit_y
                sparseNoise(ii,4) = 11;
            end
        end
    end
    TaskViziVectorWithNeighborsSent = cat(2,TaskViziVectorSent(1:32),reshape(permute(sparseNoise,[2,1]),1,[]),TaskViziVectorSent(159:end));
end
end
%--------------------------------------------------------------------------
%% ---------- Go/NoGo condition (continuous trials)
function changeForceSwitchTrials(src,event)
global BehCtrl
BehCtrl.Task.forceSwitchTrials = str2double(get(BehCtrl.handles.forceSwitchTrials,'String'));
fprintf('Force switching trial after %2d continuous Go or NoGo\r\n',BehCtrl.Task.forceSwitchTrials)
end
function changeAvoidGoTrials(src,event)
global BehCtrl
BehCtrl.Task.avoidGoTrials = str2double(get(BehCtrl.handles.avoidGoTrials,'String'));
fprintf('Avoid Go trial for %2d trials after the last\r\n',BehCtrl.Task.avoidGoTrials)
end
function changeBias(src,event)
global BehCtrl
BehCtrl.Task.bias = str2double(get(BehCtrl.handles.bias,'String'));
if BehCtrl.Task.bias < 0
    error('!!Bias must be a positive value!!')
else
    fprintf('Bias is set to %2d \r\n',BehCtrl.Task.bias)
    disp('On going Go probability reset')
end
BehCtrl.Task.GoprobOnGoing = BehCtrl.Task.Goprob; 
end
%--------------------------------------------------------------------------
%% ---------- change monitor aspect ratio
function setMonitor1(src,event)
global BehCtrl
    BehCtrl.Vizi.vectorToSend = mat2str(cat(2,[11,0],[1920,1200],zeros(1,189)));
    BehCtrl.Vizi.vectorToSend(1) = [];
    BehCtrl.Vizi.vectorToSend(end) = [];
    pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Vizi.vectorToSend);
    pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
    % update gui
    set(BehCtrl.handles.monitor1,'BackgroundColor','yellow','ForegroundColor','black');
    set(BehCtrl.handles.monitor2,'BackgroundColor',[.25 .25 .25],'ForegroundColor','white');
    set(BehCtrl.handles.monitor3,'BackgroundColor',[.25 .25 .25],'ForegroundColor','white');
    disp('monitor resolution is set to 1920 x 1200')
end
function setMonitor2(src,event)
global BehCtrl
    BehCtrl.Vizi.vectorToSend = mat2str(cat(2,[11,0],[2048,1152],zeros(1,189)));%[2048,1152]
    BehCtrl.Vizi.vectorToSend(1) = [];
    BehCtrl.Vizi.vectorToSend(end) = [];
    pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Vizi.vectorToSend);
    pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
    % update gui
    set(BehCtrl.handles.monitor2,'BackgroundColor','yellow','ForegroundColor','black');
    set(BehCtrl.handles.monitor1,'BackgroundColor',[.25 .25 .25],'ForegroundColor','white');
    set(BehCtrl.handles.monitor3,'BackgroundColor',[.25 .25 .25],'ForegroundColor','white'); 
    disp('monitor aspect ratio is set to 2048 x 1152 (mesoscope)')
end
function setMonitor3(src,event)
global BehCtrl
    BehCtrl.Vizi.vectorToSend = mat2str(cat(2,[11,0],[1680 1050],zeros(1,189)));
    BehCtrl.Vizi.vectorToSend(1) = [];
    BehCtrl.Vizi.vectorToSend(end) = [];
    pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Vizi.vectorToSend);
    pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
    % update gui
    set(BehCtrl.handles.monitor3,'BackgroundColor','yellow','ForegroundColor','black');
    set(BehCtrl.handles.monitor1,'BackgroundColor',[.25 .25 .25],'ForegroundColor','white');
    set(BehCtrl.handles.monitor2,'BackgroundColor',[.25 .25 .25],'ForegroundColor','white');  
    disp('monitor aspect ratio is set to 1680 x 1050 (box)')
    
    % box training mode
    % update the patch positions for box monitors
    
%     % update the visualization of hole positions
%     visualizeTargetPosition;
%     
%     % set to one direction mode
%     BehCtrl.Task.oneDirectionMode = true;
%     set(BehCtrl.handles.oneDirectionMode,'String','One Direction','BackgroundColor',[0 0.8 0]);
%     set(BehCtrl.handles.TaskDirection,'enable','on');
%     
%     for I = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,1)
%         for III = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,3)
%             BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,13,III) = 15; % grating direction
%             BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,14,III) = 40; % grating SF
%             BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,26,III) = 4000; % target patch size
%         end
%     end
end
%--------------------------------------------------------------------------
%% ---------- others
function switchGalvoOrIteration(src,event)
global BehCtrl
if src.Value == 1 % Galvo (default)
    BehCtrl.GalvoOrIteration = 1;
    disp('galvo signal is plotted')
elseif src.Value == 2 % code iteration
    BehCtrl.GalvoOrIteration = 2;
    disp('code iteration is plotted')  
end
end

% experiment mode
function chooseExperimentMode
screenSize = get(groot,'Screensize');
f = figure;
f.Position = [screenSize(3)*0.5,screenSize(4)*0.5,screenSize(3)*0.3,screenSize(4)*0.1];
f.Name = '!! Select Experiment Mode, and then close Window !!';
f.NumberTitle = 'off';
% ax = axes(f);
% ax.Units = 'pixels';
% ax.Position = [75 75 325 280];
c = uicontrol;
c.Style = 'popup';
c.String = {'Box training','macbook coding','2pRAM imaging'};
c.Units = 'normalized';
c.Position = [0.35 0.55 0.3 0.05];


c.Callback = @swichExperimentMode;
waitfor(f)
    function swichExperimentMode(src,event)
        global BehCtrl
        if src.Value == 1 % box training
            BehCtrl.experimentMode = 1;

        elseif src.Value == 2 % macbook coding
            BehCtrl.experimentMode = 2;

        elseif src.Value == 3 % 2pram imaging
            BehCtrl.experimentMode = 3;

        end
    end

end
%--------------------------------------------------------------------------
%% ---------- new to ATTEN
function convertAndsendVizivector(viziVector)
% viziVector is a vector with number
% this function is to fix weird behaviour of the last sine wave grating
% can't be used for monitor resolution change, because the input viziVector
% already have [0,0] at the start 
global BehCtrl
    viziString = mat2str(viziVector);
    viziString(1) = [];
    viziString(end) = [];
    viziString = strcat('[',viziString,' 0 ]');
    % send it
    pnet(BehCtrl.Vizi.sock,'write',viziString);
    pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
end  
function updateStimMat(src,event)
global BehCtrl

% update BehCtrl.LSNvectorLibrary.AllvectorsToBeSent
if ~isempty(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent)
    for I = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,1)
        for III = 1:size(BehCtrl.LSNvectorLibrary.AllvectorsToBeSent,3)
            % for bar mode
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,9:14,III) = BehCtrl.Vizi.grating1;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,15:20,III) = BehCtrl.Vizi.grating2;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,21:26,III) = BehCtrl.Vizi.foreground;            
            % sine waves
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,159:165,III) = BehCtrl.Vizi.sine_one;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,166:172,III) = BehCtrl.Vizi.sine_two;
            BehCtrl.LSNvectorLibrary.AllvectorsToBeSent(I,173:179,III) = BehCtrl.Vizi.sine_three;
        end
    end    
end

% update BehCtrl.LSNStimMat
BehCtrl.LSNStimMat(:,9:14) = repmat(BehCtrl.Vizi.grating1,size(BehCtrl.LSNStimMat,1),1);
BehCtrl.LSNStimMat(:,15:20) = repmat(BehCtrl.Vizi.grating2,size(BehCtrl.LSNStimMat,1),1);
BehCtrl.LSNStimMat(:,21:26) = repmat(BehCtrl.Vizi.foreground,size(BehCtrl.LSNStimMat,1),1);

BehCtrl.LSNStimMat(:,159:165) = repmat(BehCtrl.Vizi.sine_one,size(BehCtrl.LSNStimMat,1),1);
BehCtrl.LSNStimMat(:,166:172) = repmat(BehCtrl.Vizi.sine_two,size(BehCtrl.LSNStimMat,1),1);
BehCtrl.LSNStimMat(:,173:179) = repmat(BehCtrl.Vizi.sine_three,size(BehCtrl.LSNStimMat,1),1);

% update a task vector for "BehCtrl.RF.Mapping == false" mode (no sparse
% noises shown)
BehCtrl.Vizi.targetWOsparsenoise = BehCtrl.LSNStimMat(1,:);
BehCtrl.Vizi.targetWOsparsenoise(36:6:156) = 12;

end
function updateHolePosition(src,event)
global BehCtrl
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')
    BehCtrl.Task.holePositionMat = cat(1,BehCtrl.Sine.position_one,...
                                         BehCtrl.Sine.position_two,...
                                         BehCtrl.Sine.position_three);  
elseif strcmp(BehCtrl.Task.numPatchMode,'2_patch')
    BehCtrl.Task.holePositionMat = cat(1,BehCtrl.Sine.position_one,...
                                         BehCtrl.Sine.position_two); 
elseif strcmp(BehCtrl.Task.numPatchMode,'1_patch')
    BehCtrl.Task.holePositionMat = cat(1,BehCtrl.Sine.position_one);                                       
end
end
%--------------------------------------------------------------------------
%% ---------- related to catch trials
function updatenumPatchMode(src,event)
global BehCtrl
val = src.Value;
type = src.String;
% update here
BehCtrl.Task.numPatchMode = type{val};
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')
    BehCtrl.Task.allLocation = 1:3;
    BehCtrl.Task.distLocations(BehCtrl.Task.allLocation == BehCtrl.Task.gngLocation) = []; 
    
    set(BehCtrl.handles.patchLocation_One,'enable','on');
    set(BehCtrl.handles.patchLocation_Two,'enable','on');
    set(BehCtrl.handles.patchLocation_Three,'enable','on');

    
    set(BehCtrl.handles.slider_holeSize,'enable','off');
    set(BehCtrl.handles.enterholeSize,'enable','off');
    set(BehCtrl.handles.slider_size,'enable','on');
    set(BehCtrl.handles.enterSize,'enable','on');
    set(BehCtrl.handles.slider_targetSF,'enable','on');
    set(BehCtrl.handles.enter_targetSF,'enable','on');
    
    set(BehCtrl.handles.slider_one_azimuth,'enable','on');
    set(BehCtrl.handles.slider_two_azimuth,'enable','on');
    set(BehCtrl.handles.slider_three_azimuth,'enable','on');
    set(BehCtrl.handles.slider_bar_azimuth,'enable','off');
    
    set(BehCtrl.handles.slider_one_altitude,'enable','on');
    set(BehCtrl.handles.slider_two_altitude,'enable','on');
    set(BehCtrl.handles.slider_three_altitude,'enable','on');
    set(BehCtrl.handles.slider_bar_altitude,'enable','off');
    
    set(BehCtrl.handles.enter_one_azimuth,'enable','on');
    set(BehCtrl.handles.enter_two_azimuth,'enable','on');
    set(BehCtrl.handles.enter_three_azimuth,'enable','on');
    set(BehCtrl.handles.enter_bar_azimuth,'enable','off'); 
    
    set(BehCtrl.handles.enter_one_altitude,'enable','on');
    set(BehCtrl.handles.enter_two_altitude,'enable','on');
    set(BehCtrl.handles.enter_three_altitude,'enable','on');
    set(BehCtrl.handles.enter_bar_altitude,'enable','off');
    % set the default target locations
    BehCtrl.Sine.position_one = [300,200];
    BehCtrl.Sine.position_two = [-250,200];
    BehCtrl.Sine.position_three = [25,-300];
    % for avoid zone
    BehCtrl.Task.holePositionMat = cat(1,BehCtrl.Sine.position_one,...
                                         BehCtrl.Sine.position_two,...
                                         BehCtrl.Sine.position_three);        
    % define which elements in a Vizi vector to be modified to bring them
    % up
    BehCtrl.Task.tobeBroughtUp = [162,169,176];    
    % apply the change
    BehCtrl.Vizi.sine_one(2) = BehCtrl.Sine.position_one(1);
    BehCtrl.Vizi.sine_two(2) = BehCtrl.Sine.position_two(1);
    BehCtrl.Vizi.sine_three(2) = BehCtrl.Sine.position_three(1);
    BehCtrl.Vizi.sine_one(3) = BehCtrl.Sine.position_one(2);
    BehCtrl.Vizi.sine_two(3) = BehCtrl.Sine.position_two(2);
    BehCtrl.Vizi.sine_three(3) = BehCtrl.Sine.position_three(2);  
    updateStimMat;

    
    % set the target location to One (default)
    go_is_one;
    % [ONLY FOR TRAINING PURPOSE]
    set(BehCtrl.handles.changeTargetLocation,'enable','off','Value',0,'String','Shift Target?','BackgroundColor',[1,0.4,0.15],'ForegroundColor','white');
    set(BehCtrl.handles.changeTargetEveryNtrials,'enable','off'); 
    BehCtrl.Task.changeTargetLocation = false;
    
    % set unused location's color to be white
    BehCtrl.Sine.color_bar = 'w';     
elseif strcmp(BehCtrl.Task.numPatchMode,'2_patch')    
    BehCtrl.Task.allLocation = 1:2;
    BehCtrl.Task.distLocations(BehCtrl.Task.allLocation == BehCtrl.Task.gngLocation) = [];
    
    set(BehCtrl.handles.patchLocation_One,'enable','on');
    set(BehCtrl.handles.patchLocation_Two,'enable','on');
    set(BehCtrl.handles.patchLocation_Three,'enable','off','String','not used','BackgroundColor', [.5,.5,.5]);    

    
    set(BehCtrl.handles.slider_holeSize,'enable','off');
    set(BehCtrl.handles.enterholeSize,'enable','off');
    set(BehCtrl.handles.slider_size,'enable','on');
    set(BehCtrl.handles.enterSize,'enable','on');
    set(BehCtrl.handles.slider_targetSF,'enable','on');
    set(BehCtrl.handles.enter_targetSF,'enable','on');   
    
    set(BehCtrl.handles.slider_one_azimuth,'enable','on');
    set(BehCtrl.handles.slider_two_azimuth,'enable','on');
    set(BehCtrl.handles.slider_three_azimuth,'enable','off');
    set(BehCtrl.handles.slider_bar_azimuth,'enable','off');  
    
    set(BehCtrl.handles.slider_one_altitude,'enable','on');
    set(BehCtrl.handles.slider_two_altitude,'enable','on');
    set(BehCtrl.handles.slider_three_altitude,'enable','off');
    set(BehCtrl.handles.slider_bar_altitude,'enable','off');
    
    set(BehCtrl.handles.enter_one_azimuth,'enable','on');
    set(BehCtrl.handles.enter_two_azimuth,'enable','on');
    set(BehCtrl.handles.enter_three_azimuth,'enable','off');
    set(BehCtrl.handles.enter_bar_azimuth,'enable','off');
    
    set(BehCtrl.handles.enter_one_altitude,'enable','on');
    set(BehCtrl.handles.enter_two_altitude,'enable','on');
    set(BehCtrl.handles.enter_three_altitude,'enable','off');
    set(BehCtrl.handles.enter_bar_altitude,'enable','off'); 
    % set the default target locations
    BehCtrl.Sine.position_one = [280,-265];%[350,-60];%[300,200] in 3 patch mode
    BehCtrl.Sine.position_two = [-220,265];%[-220,160];%[-250,200] in 3 patch mode    
    
    % for avoid zone
    BehCtrl.Task.holePositionMat = cat(1,BehCtrl.Sine.position_one,...
                                         BehCtrl.Sine.position_two);      
    % define which elements in a Vizi vector to be modified to bring them
    % up
    BehCtrl.Task.tobeBroughtUp = [162,169];       
    % apply the change
    BehCtrl.Vizi.sine_one(2) = BehCtrl.Sine.position_one(1);
    BehCtrl.Vizi.sine_two(2) = BehCtrl.Sine.position_two(1);
    BehCtrl.Vizi.sine_one(3) = BehCtrl.Sine.position_one(2);
    BehCtrl.Vizi.sine_two(3) = BehCtrl.Sine.position_two(2);
    updateStimMat;  
    % set unused location's color to be white
    BehCtrl.Sine.color_three = 'w';
    BehCtrl.Sine.color_bar = 'w';   

    
    % set the target location to One (default)
    go_is_one;
    
    % [ONLY FOR TRAINING PURPOSE]
    set(BehCtrl.handles.changeTargetLocation,'enable','on');
    set(BehCtrl.handles.changeTargetEveryNtrials,'enable','on');
    BehCtrl.Task.currentShiftingTarget_one = BehCtrl.Task.targetLocations_twoPatch(1,:);                                     
    BehCtrl.Task.currentShiftingTarget_two = BehCtrl.Task.targetLocations_twoPatch(3,:);    
elseif strcmp(BehCtrl.Task.numPatchMode,'1_patch') 
    BehCtrl.Task.allLocation = 1;
    BehCtrl.Task.distLocations = [];
    set(BehCtrl.handles.patchLocation_One,'enable','on');
    set(BehCtrl.handles.patchLocation_Two,'enable','off','String','not used','BackgroundColor', [.5,.5,.5]); 
    set(BehCtrl.handles.patchLocation_Three,'enable','off','String','not used','BackgroundColor', [.5,.5,.5]);    

    
    % set the default target locations and heights for all four
    
    % set the probability of catch trials zero
    BehCtrl.Task.Catchprob = 0;
    % update the gui
    set(BehCtrl.handles.Catchprob,'String',num2str(BehCtrl.Task.Catchprob));
    set(BehCtrl.handles.slider_holeSize,'enable','off');
    set(BehCtrl.handles.enterholeSize,'enable','off');
    set(BehCtrl.handles.slider_size,'enable','on');
    set(BehCtrl.handles.enterSize,'enable','on');
    set(BehCtrl.handles.slider_targetSF,'enable','on');
    set(BehCtrl.handles.enter_targetSF,'enable','on');  
    
    set(BehCtrl.handles.slider_one_azimuth,'enable','on');
    set(BehCtrl.handles.slider_two_azimuth,'enable','off');
    set(BehCtrl.handles.slider_three_azimuth,'enable','off');
    set(BehCtrl.handles.slider_bar_azimuth,'enable','off');
    
    set(BehCtrl.handles.slider_one_altitude,'enable','on');
    set(BehCtrl.handles.slider_two_altitude,'enable','off');
    set(BehCtrl.handles.slider_three_altitude,'enable','off');
    set(BehCtrl.handles.slider_bar_altitude,'enable','off');
    
    set(BehCtrl.handles.enter_one_azimuth,'enable','on');
    set(BehCtrl.handles.enter_two_azimuth,'enable','off');
    set(BehCtrl.handles.enter_three_azimuth,'enable','off');
    set(BehCtrl.handles.enter_bar_azimuth,'enable','off'); 
    
    set(BehCtrl.handles.enter_one_altitude,'enable','on');
    set(BehCtrl.handles.enter_two_altitude,'enable','off');
    set(BehCtrl.handles.enter_three_altitude,'enable','off');
    set(BehCtrl.handles.enter_bar_altitude,'enable','off');
    % set the default target locations
    BehCtrl.Sine.position_one = [0,0];
    % for avoid zone
    BehCtrl.Task.holePositionMat = cat(1,BehCtrl.Sine.position_one);       
    % define which elements in a Vizi vector to be modified to bring them
    % up
    BehCtrl.Task.tobeBroughtUp = 162;       
    % apply the change
    BehCtrl.Vizi.sine_one(2) = BehCtrl.Sine.position_one(1);
    BehCtrl.Vizi.sine_one(3) = BehCtrl.Sine.position_one(2);
    updateStimMat;   
    % set unused location's color to be white
    BehCtrl.Sine.color_two = 'w';
    BehCtrl.Sine.color_three = 'w';
    BehCtrl.Sine.color_bar = 'w'; 
    % set the target location to One (default)
    go_is_one; 
    % just in case
    BehCtrl.Task.numHitsBeforecatch = 10000;
    set(BehCtrl.handles.numHitsBeforecatch,'String',num2str(BehCtrl.Task.numHitsBeforecatch));
%     % [ONLY FOR TRAINING PURPOSE]
%     set(BehCtrl.handles.changeTargetLocation,'enable','off','Value',0,'String','Shift Target?','BackgroundColor',[1,0.4,0.15],'ForegroundColor','white');
%     set(BehCtrl.handles.changeTargetEveryNtrials,'enable','off'); 
%     BehCtrl.Task.changeTargetLocation = false;
    % [ONLY FOR TRAINING PURPOSE]
    set(BehCtrl.handles.changeTargetLocation,'enable','on');
    set(BehCtrl.handles.changeTargetEveryNtrials,'enable','on');
    BehCtrl.Task.currentShiftingTarget_one = [0,0];
elseif strcmp(BehCtrl.Task.numPatchMode,'1_patch_bar')% only for training 
    BehCtrl.Task.distLocations = [];
    set(BehCtrl.handles.patchLocation_One,'enable','off','String','not used','BackgroundColor', [.5,.5,.5]); 
    set(BehCtrl.handles.patchLocation_Two,'enable','off','String','not used','BackgroundColor', [.5,.5,.5]); 
    set(BehCtrl.handles.patchLocation_Three,'enable','off','String','not used','BackgroundColor', [.5,.5,.5]);    
    
    
    % set the probability of catch trials zero
    BehCtrl.Task.Catchprob = 0;
    % update the gui
    set(BehCtrl.handles.Catchprob,'String',num2str(BehCtrl.Task.Catchprob));
    set(BehCtrl.handles.slider_holeSize,'enable','on');
    set(BehCtrl.handles.enterholeSize,'enable','on');
    set(BehCtrl.handles.slider_size,'enable','off');
    set(BehCtrl.handles.enterSize,'enable','off');
    set(BehCtrl.handles.slider_targetSF,'enable','off');
    set(BehCtrl.handles.enter_targetSF,'enable','off');
    
    set(BehCtrl.handles.slider_one_azimuth,'enable','off');
    set(BehCtrl.handles.slider_two_azimuth,'enable','off');
    set(BehCtrl.handles.slider_three_azimuth,'enable','off');
    set(BehCtrl.handles.slider_bar_azimuth,'enable','on');
    
    set(BehCtrl.handles.slider_one_altitude,'enable','off');
    set(BehCtrl.handles.slider_two_altitude,'enable','off');
    set(BehCtrl.handles.slider_three_altitude,'enable','off');
    set(BehCtrl.handles.slider_bar_altitude,'enable','on');
    
    set(BehCtrl.handles.enter_one_azimuth,'enable','off');
    set(BehCtrl.handles.enter_two_azimuth,'enable','off');
    set(BehCtrl.handles.enter_three_azimuth,'enable','off');
    set(BehCtrl.handles.enter_bar_azimuth,'enable','on'); 
    
    set(BehCtrl.handles.enter_one_altitude,'enable','off');
    set(BehCtrl.handles.enter_two_altitude,'enable','off');
    set(BehCtrl.handles.enter_three_altitude,'enable','off');
    set(BehCtrl.handles.enter_bar_altitude,'enable','on');
    % set unused location's color to be white
    BehCtrl.Sine.color_two = 'w';
    BehCtrl.Sine.color_three = 'w';
    BehCtrl.Sine.color_one = 'w';
    BehCtrl.Sine.color_bar = 'g';
    
    updateStimMat; 
    
    visualizeTargetPosition;
    % just in case
    BehCtrl.Task.numHitsBeforecatch = 10000;
    set(BehCtrl.handles.numHitsBeforecatch,'String',num2str(BehCtrl.Task.numHitsBeforecatch));
%     % [ONLY FOR TRAINING PURPOSE]
%     set(BehCtrl.handles.changeTargetLocation,'enable','off','Value',0,'String','Shift Target?','BackgroundColor',[1,0.4,0.15],'ForegroundColor','white');
%     set(BehCtrl.handles.changeTargetEveryNtrials,'enable','off'); 
%     BehCtrl.Task.changeTargetLocation = false; 
    % [ONLY FOR TRAINING PURPOSE]
    set(BehCtrl.handles.changeTargetLocation,'enable','on');
    set(BehCtrl.handles.changeTargetEveryNtrials,'enable','on');
    BehCtrl.Task.currentShiftingTarget_bar = [0,0];    

end



end
function go_is_one(src,event)
global BehCtrl
% define go location
BehCtrl.Task.gngLocation = 1;
BehCtrl.Task.distLocations = setdiff(BehCtrl.Task.allLocation,BehCtrl.Task.gngLocation);

% update visualisation
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')
    BehCtrl.Sine.color_one = 'g';
    BehCtrl.Sine.color_two = 'm';
    BehCtrl.Sine.color_three = 'm';
elseif strcmp(BehCtrl.Task.numPatchMode,'2_patch')
    BehCtrl.Sine.color_one = 'g';
    BehCtrl.Sine.color_two = 'm'; 
elseif strcmp(BehCtrl.Task.numPatchMode,'1_patch')
    BehCtrl.Sine.color_one = 'g';    
end
set(BehCtrl.handles.slider_one_azimuth,'backgroundcolor',BehCtrl.Sine.color_one);
set(BehCtrl.handles.slider_two_azimuth,'backgroundcolor',BehCtrl.Sine.color_two);
set(BehCtrl.handles.slider_three_azimuth,'backgroundcolor',BehCtrl.Sine.color_three);
set(BehCtrl.handles.slider_bar_azimuth,'backgroundcolor',BehCtrl.Sine.color_bar);
set(BehCtrl.handles.slider_one_altitude,'backgroundcolor',BehCtrl.Sine.color_one);
set(BehCtrl.handles.slider_two_altitude,'backgroundcolor',BehCtrl.Sine.color_two);
set(BehCtrl.handles.slider_three_altitude,'backgroundcolor',BehCtrl.Sine.color_three);
set(BehCtrl.handles.slider_bar_altitude,'backgroundcolor',BehCtrl.Sine.color_bar);
visualizeTargetPosition;

%---- update ui
set(BehCtrl.handles.patchLocation_One,'String','Go','BackgroundColor', 'green');
% others
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')  
   set(BehCtrl.handles.patchLocation_Two,'String','Distractor','BackgroundColor', 'yellow');    
   set(BehCtrl.handles.patchLocation_Three,'String','Distractor','BackgroundColor', 'yellow');  
  
elseif strcmp(BehCtrl.Task.numPatchMode,'2_patch')  
   set(BehCtrl.handles.patchLocation_Two,'String','Distractor','BackgroundColor', 'yellow');    

elseif strcmp(BehCtrl.Task.numPatchMode,'1_patch') 
   % nothing but just to avoid error
else
   error('the button for three should have been inactive...');% to be deleted 
end
%---- force to have go trial just after pressing this button
if BehCtrl.Task.started == true
    BehCtrl.Task.forceGo = true;
end


end
function go_is_two(src,event)
global BehCtrl
% define go location
BehCtrl.Task.gngLocation = 2;
BehCtrl.Task.distLocations = setdiff(BehCtrl.Task.allLocation,BehCtrl.Task.gngLocation);

% update visualisation
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')
    BehCtrl.Sine.color_one = 'm';
    BehCtrl.Sine.color_two = 'g';
    BehCtrl.Sine.color_three = 'm';      
elseif strcmp(BehCtrl.Task.numPatchMode,'2_patch')
    BehCtrl.Sine.color_one = 'm';
    BehCtrl.Sine.color_two = 'g'; 
end
set(BehCtrl.handles.slider_one_azimuth,'backgroundcolor',BehCtrl.Sine.color_one);
set(BehCtrl.handles.slider_two_azimuth,'backgroundcolor',BehCtrl.Sine.color_two);
set(BehCtrl.handles.slider_three_azimuth,'backgroundcolor',BehCtrl.Sine.color_three);
set(BehCtrl.handles.slider_bar_azimuth,'backgroundcolor',BehCtrl.Sine.color_bar);
set(BehCtrl.handles.slider_one_altitude,'backgroundcolor',BehCtrl.Sine.color_one);
set(BehCtrl.handles.slider_two_altitude,'backgroundcolor',BehCtrl.Sine.color_two);
set(BehCtrl.handles.slider_three_altitude,'backgroundcolor',BehCtrl.Sine.color_three);
set(BehCtrl.handles.slider_bar_altitude,'backgroundcolor',BehCtrl.Sine.color_bar);
visualizeTargetPosition;

%---- update ui
set(BehCtrl.handles.patchLocation_Two,'String','Go','BackgroundColor', 'green');
% others
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')  
   set(BehCtrl.handles.patchLocation_One,'String','Distractor','BackgroundColor', 'yellow');    
   set(BehCtrl.handles.patchLocation_Three,'String','Distractor','BackgroundColor', 'yellow');    
elseif strcmp(BehCtrl.Task.numPatchMode,'2_patch')  
   set(BehCtrl.handles.patchLocation_One,'String','Distractor','BackgroundColor', 'yellow');    
 
else
   error('the button for three should have been inactive...');% to be deleted 
end
%---- force to have go trial just after pressing this button
if BehCtrl.Task.started == true
    BehCtrl.Task.forceGo = true;
end

end
function go_is_three(src,event)
global BehCtrl
% define go location
BehCtrl.Task.gngLocation = 3;
BehCtrl.Task.distLocations = setdiff(BehCtrl.Task.allLocation,BehCtrl.Task.gngLocation);

% update visualisation
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')
    BehCtrl.Sine.color_one = 'm';
    BehCtrl.Sine.color_two = 'm';
    BehCtrl.Sine.color_three = 'g';      
end
set(BehCtrl.handles.slider_one_azimuth,'backgroundcolor',BehCtrl.Sine.color_one);
set(BehCtrl.handles.slider_two_azimuth,'backgroundcolor',BehCtrl.Sine.color_two);
set(BehCtrl.handles.slider_three_azimuth,'backgroundcolor',BehCtrl.Sine.color_three);
set(BehCtrl.handles.slider_bar_azimuth,'backgroundcolor',BehCtrl.Sine.color_bar);
set(BehCtrl.handles.slider_one_altitude,'backgroundcolor',BehCtrl.Sine.color_one);
set(BehCtrl.handles.slider_two_altitude,'backgroundcolor',BehCtrl.Sine.color_two);
set(BehCtrl.handles.slider_three_altitude,'backgroundcolor',BehCtrl.Sine.color_three);
set(BehCtrl.handles.slider_bar_altitude,'backgroundcolor',BehCtrl.Sine.color_bar);
visualizeTargetPosition;

%---- update ui
set(BehCtrl.handles.patchLocation_Three,'String','Go','BackgroundColor', 'green');
% others
if strcmp(BehCtrl.Task.numPatchMode,'3_patch')  
   set(BehCtrl.handles.patchLocation_One,'String','Distractor','BackgroundColor', 'yellow');    
   set(BehCtrl.handles.patchLocation_Two,'String','Distractor','BackgroundColor', 'yellow');  
else
   error('the button for three should have been inactive...');% to be deleted 
end

%---- force to have go trial just after pressing this button
if BehCtrl.Task.started == true
    BehCtrl.Task.forceGo = true;
end
end

function updateangleGo(src,event)
global BehCtrl
val = src.Value;
type = src.String;
% update here
BehCtrl.Task.angleGo = str2double(type{val});
% update for bar mode
BehCtrl.Vizi.GRone5 = BehCtrl.Task.angleGo;
BehCtrl.Vizi.grating1 = [BehCtrl.Vizi.GRone1,...
                               BehCtrl.Vizi.GRone2,...
                               BehCtrl.Vizi.GRone3,...
                               BehCtrl.Vizi.GRone4,...
                               BehCtrl.Vizi.GRone5,...
                               BehCtrl.Vizi.GRone6];
% update the stim Mat
updateStimMat;                           
end
function updateangleNogo(src,event)
global BehCtrl
val = src.Value;
type = src.String;
% update here
BehCtrl.Task.angleNogo = str2double(type{val});
% % update the sine wave vectors
% BehCtrl.Vizi.sine_one(5) = BehCtrl.Task.angleNogo;
% BehCtrl.Vizi.sine_two(5) = BehCtrl.Task.angleNogo;
% BehCtrl.Vizi.sine_three(5) = BehCtrl.Task.angleNogo;
% update for bar mode
BehCtrl.Vizi.GRtwo5 = BehCtrl.Task.angleNogo;
BehCtrl.Vizi.grating2 = [BehCtrl.Vizi.GRtwo1,...
                               BehCtrl.Vizi.GRtwo2,...
                               BehCtrl.Vizi.GRtwo3,...
                               BehCtrl.Vizi.GRtwo4,...
                               BehCtrl.Vizi.GRtwo5,...
                               BehCtrl.Vizi.GRtwo6];
% update the stim Mat
updateStimMat;
end
function updateangleDist(src,event)
global BehCtrl
val = src.Value;
type = src.String;
% update here
BehCtrl.Task.angleDist = str2double(type{val});
% update the sine wave vectors
BehCtrl.Vizi.sine_one(5) = BehCtrl.Task.angleDist;
BehCtrl.Vizi.sine_two(5) = BehCtrl.Task.angleDist;
BehCtrl.Vizi.sine_three(5) = BehCtrl.Task.angleDist;

% update the stim Mat
updateStimMat;
end    
function slideTargetSF(src,event) % this is for updating task stim (not affect SF of distructors)
global BehCtrl
BehCtrl.Task.targetSF = BehCtrl.handles.slider_targetSF.Value;
% update indicator
set(BehCtrl.handles.enter_targetSF,'String',num2str(BehCtrl.Task.targetSF));
% update the dist SF (usually it is 1.5 times more)
BehCtrl.Task.distSF = 2*BehCtrl.Task.targetSF;
set(BehCtrl.handles.enter_distSF,'String',num2str(BehCtrl.Task.distSF));
set(BehCtrl.handles.slider_distSF,'Value',BehCtrl.Task.distSF);
end    
function slideDistSF(src,event) % this is for updating task stim (not affect SF of distructors)
global BehCtrl
BehCtrl.Task.distSF = BehCtrl.handles.slider_distSF.Value;
% update indicator
set(BehCtrl.handles.enter_distSF,'String',num2str(BehCtrl.Task.distSF));
% update the sine wave vectors
BehCtrl.Vizi.sine_one(7) = BehCtrl.Task.distSF;
BehCtrl.Vizi.sine_two(7) = BehCtrl.Task.distSF;
BehCtrl.Vizi.sine_three(7) = BehCtrl.Task.distSF;
% update the stim Mat
updateStimMat;
end 
function updateTargetSF(src,event)% this is for updating task stim (not affect SF of distructors)
global BehCtrl
BehCtrl.Task.targetSF = str2double(get(BehCtrl.handles.enter_targetSF,'String'));
% update slider
set(BehCtrl.handles.slider_targetSF,'Value',BehCtrl.Task.targetSF);
% update the dist SF (usually it is 1.5 times more)
BehCtrl.Task.distSF = 2*BehCtrl.Task.targetSF;
set(BehCtrl.handles.enter_distSF,'String',num2str(BehCtrl.Task.distSF));
set(BehCtrl.handles.slider_distSF,'Value',BehCtrl.Task.distSF);
end
function updateDistSF(src,event)% this is for updating task stim (not affect SF of distructors)
global BehCtrl
BehCtrl.Task.distSF = str2double(get(BehCtrl.handles.enter_distSF,'String'));
% update slider
set(BehCtrl.handles.slider_distSF,'Value',BehCtrl.Task.distSF);
% update the sine wave vectors
BehCtrl.Vizi.sine_one(7) = BehCtrl.Task.distSF;
BehCtrl.Vizi.sine_two(7) = BehCtrl.Task.distSF;
BehCtrl.Vizi.sine_three(7) = BehCtrl.Task.distSF;
% update the stim Mat
updateStimMat;
end
function slideSize(src,event)
global BehCtrl
BehCtrl.Task.Size = BehCtrl.handles.slider_size.Value;
% update indicator
set(BehCtrl.handles.enterSize,'String',num2str(BehCtrl.Task.Size));
% update the sine wave vectors
BehCtrl.Vizi.sine_one(6) = BehCtrl.Task.Size;
BehCtrl.Vizi.sine_two(6) = BehCtrl.Task.Size;
BehCtrl.Vizi.sine_three(6) = BehCtrl.Task.Size;
% update the size of roughRF patch
BehCtrl.RoughMap.BasicVector(26) = 200*BehCtrl.Task.Size;
% update the stim Mat
updateStimMat;
end    

function updateSize(src,event)
global BehCtrl
BehCtrl.Task.Size = str2double(get(BehCtrl.handles.enterSize,'String'));
% update slider
set(BehCtrl.handles.slider_size,'Value',BehCtrl.Task.Size);
% update the sine wave vectors
BehCtrl.Vizi.sine_one(6) = BehCtrl.Task.Size;
BehCtrl.Vizi.sine_two(6) = BehCtrl.Task.Size;
BehCtrl.Vizi.sine_three(6) = BehCtrl.Task.Size;
% update the size of roughRF patch
BehCtrl.RoughMap.BasicVector(26) = 200*BehCtrl.Task.Size;
% update the stim Mat
updateStimMat;
end  
% function updateContrast(src,event)
% global BehCtrl
% val = src.Value;
% % update here
% if val ~= 5
%     BehCtrl.Task.targetID_current = 420 + val;
%     % update the first elements in sine wave vectors
%     BehCtrl.Vizi.sine_one(1) = 420 + val;
%     BehCtrl.Vizi.sine_two(1) = 420 + val;
%     BehCtrl.Vizi.sine_three(1) = 420 + val;
%     % update the stim Mat
%     updateStimMat;
%     % for meta data
%     switch val
%         case 1
%             BehCtrl.Task.contrastMode = '100';
%         case 2
%             BehCtrl.Task.contrastMode = '75';
%         case 3
%             BehCtrl.Task.contrastMode = '50';
%         case 4
%             BehCtrl.Task.contrastMode = '25';
%     end
% else % all contrast mode
%     BehCtrl.Task.contrastMode = 'all';
%     BehCtrl.Task.targetID_current = NaN;% this will be updated every trial
% end
% end
function updateContrast(src,event)
global BehCtrl
val = src.Value; % this is given as a vector with potentially multiple elements
% update here
BehCtrl.Task.targetID_candidate = 420 + val;
BehCtrl.Task.currentContrast = randi(numel(BehCtrl.Task.targetID_candidate));
BehCtrl.Task.targetID_current = BehCtrl.Task.targetID_candidate(BehCtrl.Task.currentContrast);
% do the same for distructors
BehCtrl.Task.distID_candidate = BehCtrl.Task.distID_default + val; 
BehCtrl.Task.distID_current = BehCtrl.Task.distID_candidate(BehCtrl.Task.currentContrast);
end
function flashPatch_one(event,src)
global BehCtrl
BehCtrl.RoughMap.Manual = 1;
% stimuli is updated here
BehCtrl.RoughMap.ViziVectorTobeSent = BehCtrl.RoughMap.BasicVector;
    % update hole position
    BehCtrl.RoughMap.ViziVectorTobeSent(22) = BehCtrl.Sine.position_one(1); % grating patch location;
    BehCtrl.RoughMap.ViziVectorTobeSent(23) = BehCtrl.Sine.position_one(2);
    % stim color
    BehCtrl.RoughMap.ViziVectorTobeSent(3) = datasample([1,3],1); % black or white   
    % foreground size
    BehCtrl.RoughMap.ViziVectorTobeSent(26) = 2700; %2700 corresponds to sine patch size of 12.5

% set the indicator color
set(BehCtrl.handles.flashPatch_One,'BackgroundColor',[0,1,0]); 

% start timers
start(BehCtrl.tRoughFirst);
start(BehCtrl.tRoughSecond);
% start the common clear timer
BehCtrl.tClearManualStimuli.StartDelay = 0.5;
start(BehCtrl.tClearManualStimuli);
BehCtrl.RoughMap.Manual = 0;
end
function flashPatch_two(event,src)
global BehCtrl
BehCtrl.RoughMap.Manual = 1;
% stimuli is updated here
BehCtrl.RoughMap.ViziVectorTobeSent = BehCtrl.RoughMap.BasicVector;
    % update hole position
    BehCtrl.RoughMap.ViziVectorTobeSent(22) = BehCtrl.Sine.position_two(1); % grating patch location;
    BehCtrl.RoughMap.ViziVectorTobeSent(23) = BehCtrl.Sine.position_two(2);
    % stim color
    BehCtrl.RoughMap.ViziVectorTobeSent(3) = datasample([1,3],1); % black or white   
    % foreground size
    BehCtrl.RoughMap.ViziVectorTobeSent(26) = 2700; %2700 corresponds to sine patch size of 12.5

% set the indicator color
set(BehCtrl.handles.flashPatch_Two,'BackgroundColor',[0,1,0]); 

% start timers
start(BehCtrl.tRoughFirst);
start(BehCtrl.tRoughSecond);
% start the common clear timer
BehCtrl.tClearManualStimuli.StartDelay = 0.5;
start(BehCtrl.tClearManualStimuli);
BehCtrl.RoughMap.Manual = 0;
end
function flashPatch_three(event,src)
global BehCtrl
BehCtrl.RoughMap.Manual = 1;
% stimuli is updated here
BehCtrl.RoughMap.ViziVectorTobeSent = BehCtrl.RoughMap.BasicVector;
    % update hole position
    BehCtrl.RoughMap.ViziVectorTobeSent(22) = BehCtrl.Sine.position_three(1); % grating patch location;
    BehCtrl.RoughMap.ViziVectorTobeSent(23) = BehCtrl.Sine.position_three(2);
    % stim color
    BehCtrl.RoughMap.ViziVectorTobeSent(3) = datasample([1,3],1); % black or white   
    % foreground size
    BehCtrl.RoughMap.ViziVectorTobeSent(26) = 2700; %2700 corresponds to sine patch size of 12.5

% set the indicator color
set(BehCtrl.handles.flashPatch_Three,'BackgroundColor',[0,1,0]); 

% start timers
start(BehCtrl.tRoughFirst);
start(BehCtrl.tRoughSecond);
% start the common clear timer
BehCtrl.tClearManualStimuli.StartDelay = 0.5;
start(BehCtrl.tClearManualStimuli);
BehCtrl.RoughMap.Manual = 0;
end

function removeDist(event,src)
global BehCtrl
if BehCtrl.handles.removeDistractor.Value == 1 % when button is pressed, make distractor dimmer
    % update the button color
    set(BehCtrl.handles.removeDistractor,'BackgroundColor',[0,1,0]);
    set(BehCtrl.handles.removeDistractor,'ForegroundColor',[0,0,0]);
    set(BehCtrl.handles.removeDistractor,'String','remove Dist Mode');  
    % update mode
    BehCtrl.Task.removeDistr = true;
else
    % update the button color
    set(BehCtrl.handles.removeDistractor,'BackgroundColor',[0,0.25,0]);
    set(BehCtrl.handles.removeDistractor,'ForegroundColor',[1,1,1]);
    set(BehCtrl.handles.removeDistractor,'String','dim Distr ?');
    % update mode
    BehCtrl.Task.removeDistr = false;    
end
end 
function showITIdistractor(event,src)
global BehCtrl
if BehCtrl.handles.showITIdistractor.Value == 1 % when button is pressed, make distractor dimmer
    % update the button color
    set(BehCtrl.handles.showITIdistractor,'BackgroundColor',[0,1,0]);
    set(BehCtrl.handles.showITIdistractor,'ForegroundColor',[0,0,0]);
    set(BehCtrl.handles.showITIdistractor,'String','dist Mode');  
    % update mode
    BehCtrl.Task.showITIdistractor = true;
else
    % update the button color
    set(BehCtrl.handles.showITIdistractor,'BackgroundColor',[0,0.25,0]);
    set(BehCtrl.handles.showITIdistractor,'ForegroundColor',[1,1,1]);
    set(BehCtrl.handles.showITIdistractor,'String','ITI-Dist ?');
    % update mode
    BehCtrl.Task.showITIdistractor = false;    
end
end 
function showITIdistractorOnAttended(event,src)
global BehCtrl
if BehCtrl.handles.showITIdistractorOnAttended.Value == 1 % when button is pressed, make distractor dimmer
    % update the button color
    set(BehCtrl.handles.showITIdistractorOnAttended,'BackgroundColor',[0,1,0]);
    set(BehCtrl.handles.showITIdistractorOnAttended,'ForegroundColor',[0,0,0]);
    set(BehCtrl.handles.showITIdistractorOnAttended,'String','ITIdistONatten');  
    % update mode
    BehCtrl.Task.ITIdistONattended = true;
else
    % update the button color
    set(BehCtrl.handles.showITIdistractorOnAttended,'BackgroundColor',[0,0.25,0]);
    set(BehCtrl.handles.showITIdistractorOnAttended,'ForegroundColor',[1,1,1]);
    set(BehCtrl.handles.showITIdistractorOnAttended,'String','ITI-Dist-ON-Attended?');
    % update mode
    BehCtrl.Task.ITIdistONattended = false;    
end
end 

function slideShiftAngle(src,event) % this is for updating task stim (not affect SF of distructors)
global BehCtrl
BehCtrl.Task.shiftAngle = BehCtrl.handles.shiftAngle.Value;
% update angle
BehCtrl.Task.angleGo = BehCtrl.Task.angleGo_original+ BehCtrl.Task.shiftAngle;
BehCtrl.Task.angleNogo = BehCtrl.Task.angleNogo_original + BehCtrl.Task.shiftAngle;
BehCtrl.Task.angleDist = BehCtrl.Task.angleDist_original + BehCtrl.Task.shiftAngle;
% update indicator
set(BehCtrl.handles.disp_shiftAngle,'String',num2str(BehCtrl.Task.shiftAngle));
end

function changeRandomDistProb(event,src)
global BehCtrl
BehCtrl.Task.randomDistProb = str2double(get(BehCtrl.handles.randomDistProb,'String'));
end
function changeDurationDist(event,src)
global BehCtrl
BehCtrl.Task.durationDist = str2double(get(BehCtrl.handles.durationDist,'String'));
% update num cycle
BehCtrl.Task.numCycleDist = round(BehCtrl.Task.durationDist./BehCtrl.RF.OneCycleDuration);
end

function sendDistructor_at_one(src,event)
global BehCtrl

% reset the vizi vector
BehCtrl.Vizi.vectorToSend = cat(2,[11,0],[1920,1200],zeros(1,189));
% then, modify it
BehCtrl.Vizi.vectorToSend(3:8) = [2,0,0,2,0,30]; % background
BehCtrl.Vizi.vectorToSend(159:165) = [BehCtrl.Task.distID_current,...
                                          BehCtrl.Vizi.sine_one(2),...
                                          BehCtrl.Vizi.sine_one(3),...
                                          1,...
                                          BehCtrl.Vizi.sine_one(5),...
                                          BehCtrl.Vizi.sine_one(6),...
                                          BehCtrl.Vizi.sine_one(7)];                             
% show it on the monitor
convertAndsendVizivector(BehCtrl.Vizi.vectorToSend);
end

function sendDistructor_at_two(src,event)
global BehCtrl

% reset the vizi vector
BehCtrl.Vizi.vectorToSend = cat(2,[11,0],[1920,1200],zeros(1,189));
% then, modify it
BehCtrl.Vizi.vectorToSend(3:8) = [2,0,0,2,0,30]; % background
BehCtrl.Vizi.vectorToSend(159:165) = [BehCtrl.Task.distID_current,...
                                      BehCtrl.Vizi.sine_two(2),...
                                      BehCtrl.Vizi.sine_two(3),...
                                      1,...
                                      BehCtrl.Vizi.sine_two(5),...
                                      BehCtrl.Vizi.sine_two(6),...
                                      BehCtrl.Vizi.sine_two(7)];                                      
% show it on the monitor
convertAndsendVizivector(BehCtrl.Vizi.vectorToSend);
end

function sendDistructor_at_three(src,event)
global BehCtrl

% reset the vizi vector
BehCtrl.Vizi.vectorToSend = cat(2,[11,0],[1920,1200],zeros(1,189));
% then, modify it
BehCtrl.Vizi.vectorToSend(3:8) = [2,0,0,2,0,30]; % background
BehCtrl.Vizi.vectorToSend(159:165) = [BehCtrl.Task.distID_current,...
                                      BehCtrl.Vizi.sine_three(2),...
                                      BehCtrl.Vizi.sine_three(3),...
                                      1,...
                                      BehCtrl.Vizi.sine_three(5),...
                                      BehCtrl.Vizi.sine_three(6),...
                                      BehCtrl.Vizi.sine_three(7)];                                   
% show it on the monitor
convertAndsendVizivector(BehCtrl.Vizi.vectorToSend);
end

function showPatch_one(event,src)
global BehCtrl
if BehCtrl.handles.showPatch_One.Value == 1 % when button is pressed
    % update the button color
    set(BehCtrl.handles.showPatch_One,'BackgroundColor',[0,1,0]);
    sendDistructor_at_one;
else
    % update the button color
    set(BehCtrl.handles.showPatch_One,'BackgroundColor',[0,0.25,0]);
    % then, modify it
    BehCtrl.Vizi.vectorToSend(3:8) = [2,0,0,1,0,30]; % background
    BehCtrl.Vizi.vectorToSend(159:165) = [BehCtrl.Task.distID_current,...
                                          BehCtrl.Vizi.sine_one(2),...
                                          BehCtrl.Vizi.sine_one(3),...
                                          2,...
                                          BehCtrl.Vizi.sine_one(5),...
                                          BehCtrl.Vizi.sine_one(6),...
                                          BehCtrl.Vizi.sine_one(7)];
    % show it on the monitor
    convertAndsendVizivector(BehCtrl.Vizi.vectorToSend);
end
end 
function showPatch_two(event,src)
global BehCtrl
if BehCtrl.handles.showPatch_Two.Value == 1 % when button is pressed
    % update the button color
    set(BehCtrl.handles.showPatch_Two,'BackgroundColor',[0,1,0]);
    sendDistructor_at_two;
else
    % update the button color
    set(BehCtrl.handles.showPatch_Two,'BackgroundColor',[0,0.25,0]);
    % then, modify it
    BehCtrl.Vizi.vectorToSend(3:8) = [2,0,0,1,0,30]; % background
    BehCtrl.Vizi.vectorToSend(159:165) = [BehCtrl.Task.distID_current,...
                                          BehCtrl.Vizi.sine_two(2),...
                                          BehCtrl.Vizi.sine_two(3),...
                                          2,...
                                          BehCtrl.Vizi.sine_two(5),...
                                          BehCtrl.Vizi.sine_two(6),...
                                          BehCtrl.Vizi.sine_two(7)];
    % show it on the monitor
    convertAndsendVizivector(BehCtrl.Vizi.vectorToSend);
end
end 
function showPatch_three(event,src)
global BehCtrl
if BehCtrl.handles.showPatch_Three.Value == 1 % when button is pressed
    % update the button color
    set(BehCtrl.handles.showPatch_Three,'BackgroundColor',[0,1,0]);
    sendDistructor_at_three;
else
    % update the button color
    set(BehCtrl.handles.showPatch_Three,'BackgroundColor',[0,0.25,0]);
    % then, modify it
    BehCtrl.Vizi.vectorToSend(3:8) = [2,0,0,1,0,30]; % background
    BehCtrl.Vizi.vectorToSend(159:165) = [BehCtrl.Task.distID_current,...
                                          BehCtrl.Vizi.sine_three(2),...
                                          BehCtrl.Vizi.sine_three(3),...
                                          2,...
                                          BehCtrl.Vizi.sine_three(5),...
                                          BehCtrl.Vizi.sine_three(6),...
                                          BehCtrl.Vizi.sine_three(7)];
    % show it on the monitor
    convertAndsendVizivector(BehCtrl.Vizi.vectorToSend);
end
end 

function changeTargetLocation(src,event)
global BehCtrl
val = src.Value;
type = src.String;
if strcmp(type{val},'No Shift/Noise')
    BehCtrl.Task.changeTargetLocation = false;
    BehCtrl.Task.noisyTargetLocation = false;
    set(BehCtrl.handles.noiseOnTarget,'enable','inactive');
elseif strcmp(type{val},'Shift Target')
    BehCtrl.Task.changeTargetLocation = true;
    BehCtrl.Task.noisyTargetLocation = false;    
    set(BehCtrl.handles.noiseOnTarget,'enable','inactive');
elseif strcmp(type{val},'Add Noise')
    BehCtrl.Task.changeTargetLocation = false;
    BehCtrl.Task.noisyTargetLocation = true;   
    set(BehCtrl.handles.noiseOnTarget,'enable','on');
end
end  
function changeNumTrialsToChangeTarget(src,event)
global BehCtrl
BehCtrl.Task.cumTrialNumAfterChange = 0;
BehCtrl.Task.NumTrialsToChangeTarget = str2double(get(BehCtrl.handles.changeTargetEveryNtrials,'String'));
set(BehCtrl.handles.changeTargetEveryNtrials,'String',num2str(BehCtrl.Task.NumTrialsToChangeTarget));
set(BehCtrl.handles.remainingTrials,'String',num2str(BehCtrl.Task.NumTrialsToChangeTarget));
end
function resetNtrialsCounter(src,event)
global BehCtrl
BehCtrl.Task.cumTrialNumAfterChange = 0;
set(BehCtrl.handles.changeTargetEveryNtrials,'String',num2str(BehCtrl.Task.NumTrialsToChangeTarget));
set(BehCtrl.handles.remainingTrials,'String',num2str(BehCtrl.Task.NumTrialsToChangeTarget));
end
function changeNoiseOnTarget(src,event)
global BehCtrl
BehCtrl.Task.noiseOnTarget = str2double(get(BehCtrl.handles.noiseOnTarget,'String'));
set(BehCtrl.handles.noiseOnTarget,'String',num2str(BehCtrl.Task.noiseOnTarget));
BehCtrl.Task.currentNoiseDeg_x = BehCtrl.Task.noiseOnTarget*rand(1)*sign(rand(1)-0.5);
BehCtrl.Task.currentNoiseDeg_y = BehCtrl.Task.noiseOnTarget*rand(1)*sign(rand(1)-0.5);
end
%--------------------------------------------------------------------------
%% ---------- Stop & Clean up
function my_stopfcn(src,event)
global BehCtrl
% delete licklisteners if not deleted yet
if  isfield(BehCtrl,'licklistener_Rew')
delete(BehCtrl.licklistener_Rew)
end
if  isfield(BehCtrl,'licklistener_Puff')
delete(BehCtrl.licklistener_Puff)
end
if isfield(BehCtrl,'licklistener_earlyLick')
    delete(BehCtrl.licklistener_earlyLick)
end

% stop and delete all timers from memory
if ~isempty(timerfind)
    stop(timerfind)
    delete(timerfind)
end
if isfield(BehCtrl,'stop')
set(BehCtrl.handles.stop, 'enable','off')
end
if isfield(BehCtrl,'sess')
 stop(BehCtrl.sess); % how to properly close it?
 BehCtrl = rmfield(BehCtrl,'sess');
end
if isfield(BehCtrl,'Digsess')
 stop(BehCtrl.Digsess);
 BehCtrl = rmfield(BehCtrl,'Digsess');
end

% this is text file with information about RF stimuli and Task
if isfield(BehCtrl,'Save.fileID')
    fclose(BehCtrl.Save.fileID);
end
if isfield(BehCtrl,'Save.AI')
    fclose(BehCtrl.Save.AI);
end
% switch the monitor to gray screen
pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Vizi.justGrayString); % this is already string
pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
% enable on?
fprintf('stopped\n')
% what else needs cleaning?
BehCtrl.Task.stopped = 1;
% overwrite meta data file (if saving)
if BehCtrl.handles.startSaving.Value == 1
    saveMetaData;
    disp('meta data is overwritten')
end
end
function taskStopfcn(src,event)% after timelimit, just task is stopped but recording keeps going
global BehCtrl
% delete licklisteners if not deleted yet
if  isfield(BehCtrl,'licklistener_Rew')
delete(BehCtrl.licklistener_Rew)
end
if  isfield(BehCtrl,'licklistener_Puff')
delete(BehCtrl.licklistener_Puff)
end
if isfield(BehCtrl,'licklistener_earlyLick')
    delete(BehCtrl.licklistener_earlyLick)
end

% stop and delete all timers from memory
if ~isempty(timerfind)
    stop(timerfind)
    delete(timerfind)
end

% switch the monitor to gray screen
pnet(BehCtrl.Vizi.sock,'write',BehCtrl.Vizi.justGrayString); % this is already string
pnet(BehCtrl.Vizi.sock,'writepacket',BehCtrl.localip,BehCtrl.Vizi.UDPUnity);
% message
disp('!stop recording!')
% 
    set(BehCtrl.handles.PuffZone,'BackgroundColor','red')
    set(BehCtrl.handles.RFMap,'BackgroundColor','red')
    set(BehCtrl.handles.ITIZone,'BackgroundColor','red') 
    set(BehCtrl.handles.RewZone,'BackgroundColor','red')
end
function my_closefcn(src,event)
global BehCtrl

if ~BehCtrl.Task.stopped  % if gui is closed without pressing stop button
    my_stopfcn(src,event);
end

% close UDP connection
try
    pnet(BehCtrl.Vizi.sock, 'close')
    disp('UDP connection is successfuly closed')
catch
    disp('couldnt shut UDP connection down')
end
% just in case nidaq session is not closed properly
if isfield(BehCtrl,'lh')
    delete(BehCtrl.lh)
end
if isfield(BehCtrl,'sess')
    stop(BehCtrl.sess)
end
if isfield(BehCtrl,'Digsess')
    stop(BehCtrl.Digsess)
end
delete(gcf);
end