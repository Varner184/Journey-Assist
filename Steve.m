%% Ready Functions
%% brick = ConnectBrick('STEVE')
%% Execute before running first time
clc;

% Play sound on startup - Acknowledge ready and ask for manual speed
brick.SetColorMode(2,2);
brick.playTone(10,100,100);
pause(0.5);
brick.playTone(10,300,200);
pause(0.5);
brick.playTone(10,500, 200);
disp('STEVE is ready.');
brick.GyroCalibrate(3);
currAngle = 0;
speed = input('Set a speed (1-100): ');

%% Control Variable
manualMode = false;
leftMotor = -1 * speed;
rightMotor = -1 * speed * 1.02;
leftSpeed = -25;
rightSpeed = -25 * 0.97;
turnPause = 1.65;

%% Detection Variable
autoMoveForward = true;
canTurnRight = false;
lastTurnAngle = 0;

global key;
InitKeyboard();

while 1

  pause(0.1);

  %% Manual Control
if manualMode == true
  switch key

    case 'uparrow'

        brick.MoveMotor('A', leftMotor);
        brick.MoveMotor('D', rightMotor);

    case 'downarrow'

        brick.MoveMotor('A', leftMotor * -1);
        brick.MoveMotor('D', rightMotor * -1);

    case 'leftarrow'

        brick.MoveMotor('D', leftSpeed);
        brick.MoveMotor('A', rightSpeed * -1);

    case 'rightarrow'

        brick.MoveMotor('A', rightSpeed);
        brick.MoveMotor('D', leftSpeed * -1);

    case 0
        
        brick.StopAllMotors('Coast');

    case 'm'

        manualMode = true;

    case 'a'
        lastTurnAngle = 0;
        brick.GyroCalibrate(3);
        pause(1);
        manualMode = false;
        currAngle = 0;


    case 'c'

        brick.MoveMotor('C', 5);

    case 'o'

        brick.MoveMotor('C', -5);

    case 'q'
        disp('Quitting...');
        break;

    case 't'
        distanceRight = brick.UltrasonicDist(4);
        disp(distanceRight);
        angle = brick.GyroAngle(3);
        disp(angle);


   end
 end

  switch key
      case 'm'
          brick.StopAllMotors('Coast');
          manualMode = true;
      case 'q'
          brick.StopAllMotors('Coast');
          disp('Quitting...');
          break;

  end

  %% Wall Detection
  buttonPress = brick.TouchPressed(1);
    if buttonPress == 1
      autoMoveForward = false;
      distanceRight = brick.UltrasonicDist(4);
      if distanceRight >= 55
        % Reverse and turn right
        disp('Wall hit, reversing... Turning right');
        brick.StopAllMotors('Brake');
        brick.GyroCalibrate(3);
        pause(1);
        brick.MoveMotor('A', leftMotor * -1);
        brick.MoveMotor('D', rightMotor * -1);
        pause(1.5);
        while brick.GyroAngle(3) < lastTurnAngle + 65
            brick.MoveMotor('A', rightSpeed);
             brick.MoveMotor('D', leftSpeed * -1);
             disp(brick.GyroAngle(3));
        end
        lastTurnAngle = 0;
        disp(brick.GyroAngle(3));
        brick.MoveMotor('A', leftMotor);
        brick.MoveMotor('D', rightMotor);
        pause(0.5);
        autoMoveForward = true;
      else
        % Reverse and turn left
        disp('Wall hit, reversing... Turning left');
        brick.StopAllMotors('Brake');
        brick.GyroCalibrate(3);
        pause(1);
        brick.MoveMotor('A', leftMotor * -1);
        brick.MoveMotor('D', rightMotor * -1);
        pause(1.5);
        while brick.GyroAngle(3) > lastTurnAngle - 75
             brick.MoveMotor('D', leftSpeed);
             brick.MoveMotor('A', rightSpeed * -1);
             disp(brick.GyroAngle(3));
        end
        lastTurnAngle = 0;
        disp(brick.GyroAngle(3));
        brick.MoveMotor('A', leftMotor);
        brick.MoveMotor('D', rightMotor);
        pause(0.5);
        autoMoveForward = true;
      end
   end

  %% Color Sensor 

  color = brick.ColorCode(2);

  switch color
      %Red
      case 5
          if manualMode == false
              disp('Red detected - Stop for 1 seconds and continue');
              autoMoveForward = false;
              brick.StopAllMotors('Coast');
              pause(1);
              brick.MoveMotor('A', leftMotor);
              brick.MoveMotor('D', rightMotor);
              pause(1);
              autoMoveForward = true;
          end
      %Green - Dropoff
      case 3
          if manualMode == false
              disp('Green detected - Manual mode enabled');
              brick.StopAllMotors('Coast');
              brick.playTone(50,300,150);
              pause(0.5);
              brick.playTone(50,300,150);
              pause(0.5);
              brick.playTone(50,300,150);
              manualMode = true;
          end
      %Blue - Pickup
      case 2
          if manualMode == false
              disp('Blue detected - Manual mode enabled');
              brick.StopAllMotors('Coast');
              brick.playTone(50,300,150);
              pause(0.5);
              brick.playTone(50,300,150);
              manualMode = true;
          end
  otherwise % Autonomous Navigation
       if autoMoveForward && manualMode == false
          color = brick.ColorCode(2);
          distanceRight = brick.UltrasonicDist(4);
          currAngle = brick.GyroAngle(3);
          brick.MoveMotor('A', leftMotor);
          brick.MoveMotor('D', rightMotor);

          if distanceRight >= 55 && distanceRight < 300
             pause(2.0);
             brick.StopAllMotors('Brake');
             brick.GyroCalibrate(3);
             pause(1);
             while brick.GyroAngle(3) < lastTurnAngle + 80
                 brick.MoveMotor('A', rightSpeed);
                 brick.MoveMotor('D', leftSpeed * -1);
                 disp(brick.GyroAngle(3));
             end
             lastTurnAngle = 0;
             disp(brick.GyroAngle(3));
             brick.MoveMotor('A', leftMotor);
             brick.MoveMotor('D', rightMotor);
             pause(2);
             distanceRight = brick.UltrasonicDist(4);
          end
       end
  end

end

CloseKeyboard();
