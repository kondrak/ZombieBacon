part of zombiebacon;

double musicTimer;

class IngameState implements GameState
{
    int    _stateId = States.INGAME;
    Scene  _scene;
    bool   _mousePressed;
    int    _prevMouseX;
    int    _prevMouseY;
    bool   _musicStarted;

    void OnEnter()
    {
        this._mousePressed = false;
        this._prevMouseX = 0;
        this._prevMouseY = 0;   
        this._musicStarted = false;        

        font = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-1.85, -7.95, -1.0));
        font.scale = new Vector3(2.0, 2.0, 1.0);
        font.fixedPos = true;
        
        _scene = new Scene();

        _scene.Load();
        
        
        
        soundMgr.Toggle('intro', false);
        musicTimer = 0.0;
    }

    void OnExit()
    {

    }

    void onMouseMove(MouseEvent event)
    {
        if(!_mousePressed)
            return;

        _prevMouseX = event.client.x;
        _prevMouseY = event.client.y;

        _scene.onMouseMove(event);
        
        event.preventDefault();
    }

    void onMouseDown(MouseEvent event)
    {
        if(!_mousePressed)
        {
            _prevMouseX = event.client.x;
            _prevMouseY = event.client.y;
        }

        if (event.target == canvas)
        {         
            _mousePressed = true;
            _scene.onMouseDown(event);
        }
    }

    void onMouseUp(MouseEvent event)
    {
        _mousePressed = false;
        _scene.onMouseUp(event);
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

    void OnNewFrame(double dt)
    {        
        if(musicTimer > 3.2 && !soundMgr.isPlaying('intro') && !_musicStarted)
        {
            soundMgr.Toggle('music', true);
            _musicStarted = true;
        }
        else
        {
            musicTimer += dt / 1000.0;
        }
        
        GL.MatrixMode(MatrixModes.MODELVIEW);
        glContext.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT | WebGL.RenderingContext.DEPTH_BUFFER_BIT);
        glContext.clearColor(30.0 / 255.0, 43.0 / 255.0, 56.0 / 255.0, 1.0);

        GL.PushMatrix();
        _scene.OnNewFrame(dt);
        GL.PopMatrix();  
    }
}