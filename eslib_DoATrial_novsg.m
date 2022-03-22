%% wait button press to start a trial
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, WaitInstructionPage)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, WaitInstructionPage)
Screen('Flip', windowPtr);
pause(0.7);
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, NextTrialInstructionPage)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, NextTrialInstructionPage)
Screen('Flip', windowPtr);
KbWait;  %--- press the button for next trial
FlushEvents('keyDown');	


%% prepare the stimuli
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, VergenceAnchoringPage)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, VergenceAnchoringPage)
Screen('Flip', windowPtr);

tic
% initialize some parameters
TargetHorizontalPosition=[]; TargetVerticalPosition = [];

% Target position in search task.
%--- target could be randomly left or right (1, or 2). Here target side is
%identical to border side
Side= ceil(rand * params.stim.NBorderSides);   
% and randomly choose a vertical position
TargetVerticalPosition=params.stim.TVerticalPositions(ceil(rand(1)*NVerticalLocations));
HorizontalShift = params.stim.THorizontalShift(find(params.stim.TVerticalPositions ==TargetVerticalPosition));
TargetHorizontalPosition=params.stim.NbX/2 - (Side==1)*HorizontalShift + (Side==2)*(1+HorizontalShift);



% Item locations
RelativeCenterCoordinate = ones(params.stim.NbY,params.stim.NbX) * (SizeCube - Sizebar)/2;
CubeRelativePositionsx = ceil(RelativeCenterCoordinate + (rand(params.stim.NbY,params.stim.NbX)-0.5*ones(params.stim.NbY, params.stim.NbX)));
CubeRelativePositionsy = ceil(RelativeCenterCoordinate + (rand(params.stim.NbY,params.stim.NbX)-0.5*ones(params.stim.NbY, params.stim.NbX)));



%%
%--- StimulusContent(:, j, i) describe the identities (which is first index in the array AllCubes) of the two bars at
%grid location (j, i); This definition means that each grid location has no more
% than 2 bars. If the identity is 0, this means
% no bar. So at one location, it can have no bar, one bar,
% or two bars. So if StimulusContent(:, j, i) =
% (1, 2), it means at this location bars 1 and 2 are
% present.                          
StimulusContent = zeros( 1,params.stim.NbY, params.stim.NbX);


%--- First generate the task-relevant stimulus from condition index
randx = (rand>0.5);
BarID_Target = 1+randx;
BarID_Background = 2-randx;

StimulusContent(1, :, :) = ones(1, params.stim.NbY, params.stim.NbX);
StimulusContent(1, TargetVerticalPosition, TargetHorizontalPosition) = BarID_Background;
StimulusContent(2, :, :) = ones(1, params.stim.NbY, params.stim.NbX);
StimulusContent(3, :, :) = ones(1, params.stim.NbY, params.stim.NbX);
%--- combine the relevant and irrelevant stimuli
%- add binocular dots in each cube to anchor the vergence
% Matrix is a image matrix for the stimulus
Matrix = zeros(params.stim.NbY*SizeCube, params.stim.NbX*SizeCube);
Matrix_BG = Matrix;
for ibX = 1:params.stim.NbX
    if mod(ibX,2)==1
        for jbY = 1:params.stim.NbY
            if mod(jbY,2)==1
            ijScreenPosy = CubeRelativePositionsy(jbY,ibX) + SizeCube*(jbY-1);
            ijScreenPosx = CubeRelativePositionsx(jbY,ibX) + SizeCube*(ibX-1);
            Matrix_BG(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar)=CubeHorizental;         
            elseif mod(jbY,2)==0
            ijScreenPosy = CubeRelativePositionsy(jbY,ibX) + SizeCube*(jbY-1);
            ijScreenPosx = CubeRelativePositionsx(jbY,ibX) + SizeCube*(ibX-1);
            Matrix_BG(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar)=CubeVertical;                                                
            end
        end
    elseif mod(ibX,2)==0
        for jbY = 1:params.stim.NbY
            if mod(jbY,2)==1
                ijScreenPosy = CubeRelativePositionsy(jbY,ibX) + SizeCube*(jbY-1);
                ijScreenPosx = CubeRelativePositionsx(jbY,ibX) + SizeCube*(ibX-1);              
                Matrix_BG(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar)=CubeVertical;                                            
            elseif mod(jbY,2)==0
                ijScreenPosy = CubeRelativePositionsy(jbY,ibX) + SizeCube*(jbY-1);
                ijScreenPosx = CubeRelativePositionsx(jbY,ibX) + SizeCube*(ibX-1);           
                Matrix_BG(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar)=CubeHorizental;                                             
            end
        end
    end
end

      

%- Left/ Right_Stimulus are image matrix contain anchor points and bars for
% left and right eye respectively.
Left_Stimulus = Matrix; Right_Stimulus = Matrix;
for ibX=1:params.stim.NbX
    for jbY=1:params.stim.NbY
        ijScreenPosy = CubeRelativePositionsy(jbY,ibX) + SizeCube*(jbY-1);
        ijScreenPosx = CubeRelativePositionsx(jbY,ibX) + SizeCube*(ibX-1);
        %--- Presentation Mode and content of the stimulus bars
                    ijkUsedCube = squeeze(AllCubes(1, :, :));
                    Left_Stimulus(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar)= ...
                        max(Left_Stimulus(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar), ijkUsedCube); %+ CubeHorizental
                    Right_Stimulus(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar)= ...
                        max(Right_Stimulus(ijScreenPosy+1:ijScreenPosy+Sizebar, ijScreenPosx+1:ijScreenPosx+Sizebar), ijkUsedCube);
          
        
    end
end


% Open offscreen for left and right eye image
LeftStimulusPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
LeftStimulusPtr = Screen('MakeTexture', windowPtr, Left_Stimulus);
Screen('DrawTexture', LeftStimulusPage, LeftStimulusPtr);
Screen('FillOval', LeftStimulusPage, params.screen.FOR_COLOR, FourDots_rect);

RightStimulusPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
RightStimulusPtr = Screen('MakeTexture', windowPtr, Right_Stimulus);
Screen('DrawTexture', RightStimulusPage, RightStimulusPtr);
Screen('FillOval', RightStimulusPage, params.screen.FOR_COLOR, FourDots_rect);

% to let the fixation dot the same time that is around 1.2 sec
t = toc;
pause(1.2-t);

%% present the stimuli
% coding using PTB built-in stereoscopitic method, for easy transfer to
% other type of stereo mode, as well as better graphical performance.

FlushEvents('keyDown');  % Discard all the chars from the Event Manager queue.
% select the canvas for left eye input and draw
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, LeftStimulusPage)
% select the canvas for right eye input and draw
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, RightStimulusPage)
% Show the canvas on the screen
[~,StimulusOnsetTimeSec] = Screen('Flip', windowPtr);
% [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = 
%      Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
% Flip (optionally) returns a high-precision estimate of the system time
%    (in seconds) when the actual flip has happened in the return argument
%    'VBLTimestamp'. (VBL: vertical retrace) 
% An estimate of Stimulus-onset time is returned in 'StimulusOnsetTime'. 
% 'FlipTimestamp' is a timestamp taken at the end of Flip's execution.    

%% -- wait for the response
[keyPressTimeSec, keyCode] = KbWait;
% [secs, keyCode, deltaSecs] = KbWait([deviceNumber][, forWhat=0][, untilTime=inf])
% Waits until any key is down and optionally returns the time in seconds
%   and the keyCode vector of keyboard states,
% CAUTION: KbWait periodically checks the keyboard. After each failed check
%   (ie. no change in keyboard state) it will wait for 5 msecs before the
%   next check. This is done to reduce the load on your system, and it is
%   important to do so. However if you want to measure reaction times this is
%   clearly not what you want, as it adds up to 5 msecs extra uncertainty to
%   all measurements!

% record which key was pressed
char = KbName(keyCode);
% Response Time of button press
RT = keyPressTimeSec-StimulusOnsetTimeSec;

FlushEvents('keyDown');	% Discard all the chars from the Event Manager queue.

%% clear buffer
% Clear buffers and textures which will not be used anymore to prevent
% overload of the graphic memory.
Screen('Close', LeftStimulusPage);
Screen('Close', RightStimulusPage);
Screen('Close', LeftStimulusPtr);
Screen('Close', RightStimulusPtr);




