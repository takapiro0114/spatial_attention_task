classdef BehState_MaPlas < handle
    events
        TrialStart        
        RewZone
        PuffZone
        MouseLicked 
        InterTrialInterval
        TrialEnd
    end
    methods
        function triggerTrialStart(obj)
            disp('BehState: trial started')
            notify(obj,'TrialStart')
        end        
        function triggerRewZone(obj)           
            disp('BehState: entered reward zone')
            notify(obj,'RewZone')
        end
        function triggerPuffZone(obj)           
            disp('BehState: entered puff zone')
            notify(obj,'PuffZone')
        end
        function triggerMouseLicked(obj)
            disp('BehState: mouse licked')
            notify(obj,'MouseLicked')
        end
        function triggerITI(obj)
            disp('BehState: ITI started')
            notify(obj,'InterTrialInterval')
        end   
        function triggerTrialEnd(obj)
            disp('BehState: trial ended')
            notify(obj,'TrialEnd')
        end        
    end
end