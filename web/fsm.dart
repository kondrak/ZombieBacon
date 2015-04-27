part of zombiebacon;

class States
{
    static const int LOADING = 0;
    static const int INGAME  = 1;
}

abstract class GameState
{
    int _stateId;

    void OnEnter();
    void OnExit();
    void OnNewFrame(double dt);
    void onMouseMove(MouseEvent event);
    void onMouseDown(MouseEvent event);
    void onMouseUp(MouseEvent event);
    void onKeyDown(KeyboardEvent event);
    void onKeyUp(KeyboardEvent event);
    void onFocus(Event event);
    void onBlur(Event event);
}

class FSM
{
    void SetState(int state)
    {
        if(currentState != null)
        {
            if(state == currentState._stateId)
                return;

            currentState.OnExit();
        }

        switch(state)
        {
        case States.LOADING:
            currentState = new LoadingState();
            break;
        case States.INGAME:
            currentState = new IngameState();
            break;
        }

        currentState.OnEnter();
    }

    void onMouseMove(MouseEvent event)
    {
        if(currentState != null)
            currentState.onMouseMove(event);
    }

    void onMouseDown(MouseEvent event)
    {
        if(currentState != null)
            currentState.onMouseDown(event);
    }

    void onMouseUp(MouseEvent event)
    {
        if(currentState != null)
            currentState.onMouseUp(event);
    }

    void onKeyDown(KeyboardEvent event)
    {
        if(currentState != null)
            currentState.onKeyDown(event);
    }

    void onKeyUp(KeyboardEvent event)
    {
        if(currentState != null)
            currentState.onKeyUp(event);
    }
    
    void onFocus(Event event)
    {
        if(currentState != null)
            currentState.onFocus(event);
    }
    
    void onBlur(Event event)
    {
        if(currentState != null)
            currentState.onBlur(event);
    }

    void OnNewFrame(double dt)
    {
        if(currentState != null)
            currentState.OnNewFrame(dt);
    }

    GameState currentState;
}


class LoadingState implements GameState
{
    int _stateId = States.LOADING;
    Font loadingText;
    
    void OnNewFrame(double dt)
    {
        GL.MatrixMode(MatrixModes.MODELVIEW);
        glContext.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT | WebGL.RenderingContext.DEPTH_BUFFER_BIT);
        glContext.clearColor(0.0, 0.0, 0.0, 1.0);
        
        if(texMgr.allTexLoaded)
        {
            if(loadingText == null)
            {
                loadingText = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-3.8 / scaleX, 0.0, -1.0));
                loadingText.scale = new Vector3(2.5, 2.5, 1.0);
                loadingText.fixedPos = true;       
            }                    
        
            camDirector.activeCamera.SetMode(CameraMode.ORTHO);
            GL.PushMatrix();
            loadingText.drawText("NOW LOADING DISK 1...", new Vector4(1.0, 1.0, 1.0, 1.0));
            GL.PopMatrix();
        }
        
        if(soundMgr.allSoundsLoaded && texMgr.allTexLoaded)
            fsm.SetState(States.INGAME);
    }    
    
    void OnEnter()
    {
        camDirector.ClearAll();

        Camera camera = new Camera(new Vector3(0.0, 0.0, 5.0),
                                   CameraMode.ORTHO,
                                   double.parse(canvas.getAttribute("width")),
                                   double.parse(canvas.getAttribute("height")));

        camera.Move(new Vector3(camera._aspectRatio, -1.0, 0.0));
        camDirector.AddCamera(camera);
        camDirector.activeCamera.OnNewFrame(0.0);
    }

    void OnExit()
    {

    }

    void onMouseMove(MouseEvent event)
    {

    }

    void onMouseDown(MouseEvent event)
    {

    }

    void onMouseUp(MouseEvent event)
    {

    }

    void onKeyDown(KeyboardEvent event)
    {

    }

    void onKeyUp(KeyboardEvent event)
    {

    }
    
    void onFocus(Event event)
    {
        
    }
    
    void onBlur(Event event)
    {
        
    }
}
