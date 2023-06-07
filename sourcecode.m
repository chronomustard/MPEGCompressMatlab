classdef runthis < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        PlaySequenceButton              matlab.ui.control.StateButton
        EncodeandDecodeButton           matlab.ui.control.StateButton
        MPEGCompressionSimulationLabel  matlab.ui.control.Label
        UIAxes_2                        matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Callback function
        function KembaliButtonValueChanged(app, event)
            app4;
            closereq();
        end

        % Callback function
        function MenuButtonValueChanged(app, event)
            homepage;
            closereq();
        end

        % Value changed function: EncodeandDecodeButton
        function EncodeandDecodeButtonValueChanged(app, event)
            image = imread('coastguard003.tiff');
            [frameY, frameCr, frameCb] = ccir2ycrcb(image);
            mBYprev=uint8(frameY(1:16,1:16));
            
            refImage = imread('coastguard001.tiff');
            [refFrameY, refFrameCr, refFrameCb] = ccir2ycrcb(refImage);
            mBIndex=0;
            [eMBY, eMBCr, eMBCb, mV] = motEstP(frameY, frameCr, frameCb, mBIndex, refFrameY, refFrameCr, refFrameCb);
            [mBY, mBCr, mBCb] = iMotEstP(eMBY, eMBCr, eMBCb, mBIndex, mV, refFrameY, refFrameCr, refFrameCb);
            
            mBYprev=single(frameY(1:16,1:16));
            predError=mBYprev-mBY;
            imwrite(predError, 'predError.png');
            
            bName = 'coastguard';
            fExtension = '.tiff';
            startFrame = 0;
            numOfGoPs =4;
            qScale =8;
            SeqEntity=encodeMPEG(bName, fExtension, startFrame, numOfGoPs, qScale);
            
            save('seq','SeqEntity')
            
            size = getSeqEntityBits(SeqEntity);
            fprintf('Size of encoded file: %d Bytes\n',size/8);
            
            outFName = 'decoded_coastguard';
            fName = 'seq';
            decodeMPEG(fName, outFName);
            
            % compute mean errors
            meanErrors=[];
            meaner=[];
            for i=0:11 
                orig = sprintf('%s%03d%s',bName,i,'.tiff');
                dec = sprintf('%s%03d%s',outFName,i,'.tiff');
                
                if exist(dec,'file')==2
                    originalFrame = imread(orig);
                    decFrame = imread(dec);
                    
                    error = abs(originalFrame-decFrame);
                    meanErrors=[meanErrors;i mean2(error)];
                end
            end
            % the first column is the number of the image
            % and the second is the value of the mean error
            meanErrors
            for n=1:11
              images{n} = imread(sprintf('coastguard%03d.tiff',n));
              images_dec{n} = imread(sprintf('decoded_coastguard%03d.tiff',n));
            end
            for n=1:11
               images{n} = imshow(sprintf('coastguard%03d.tiff',n),'parent',app.UIAxes);
               images{n} = imshow(sprintf('decoded_coastguard%03d.tiff',n),'parent',app.UIAxes_2);
               pause(0.25);
            end
        end

        % Value changed function: PlaySequenceButton
        function PlaySequenceButtonValueChanged(app, event)
            for n=1:11
              images{n} = imread(sprintf('coastguard%03d.tiff',n));
              images_dec{n} = imread(sprintf('decoded_coastguard%03d.tiff',n));
            end
            for n=1:11
               images{n} = imshow(sprintf('coastguard%03d.tiff',n),'parent',app.UIAxes);
               images{n} = imshow(sprintf('decoded_coastguard%03d.tiff',n),'parent',app.UIAxes_2);
               pause(0.25);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1018 577];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Original Frame')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [42 99 468 424];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Decode Frame')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Position = [509 99 468 424];

            % Create MPEGCompressionSimulationLabel
            app.MPEGCompressionSimulationLabel = uilabel(app.UIFigure);
            app.MPEGCompressionSimulationLabel.HorizontalAlignment = 'center';
            app.MPEGCompressionSimulationLabel.FontSize = 20;
            app.MPEGCompressionSimulationLabel.FontWeight = 'bold';
            app.MPEGCompressionSimulationLabel.Position = [321 533 400 29];
            app.MPEGCompressionSimulationLabel.Text = 'MPEG Compression Simulation';

            % Create EncodeandDecodeButton
            app.EncodeandDecodeButton = uibutton(app.UIFigure, 'state');
            app.EncodeandDecodeButton.ValueChangedFcn = createCallbackFcn(app, @EncodeandDecodeButtonValueChanged, true);
            app.EncodeandDecodeButton.Text = 'Encode and Decode';
            app.EncodeandDecodeButton.BackgroundColor = [1 1 1];
            app.EncodeandDecodeButton.Position = [362 31 153 52];

            % Create PlaySequenceButton
            app.PlaySequenceButton = uibutton(app.UIFigure, 'state');
            app.PlaySequenceButton.ValueChangedFcn = createCallbackFcn(app, @PlaySequenceButtonValueChanged, true);
            app.PlaySequenceButton.Text = 'Play Sequence';
            app.PlaySequenceButton.BackgroundColor = [1 1 1];
            app.PlaySequenceButton.Position = [547 31 150 52];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = runthis

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end