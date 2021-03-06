library zombiebacon;

import 'dart:convert';
import 'dart:html';
import 'dart:math' as Math;
import 'dart:web_audio';
import 'dart:web_gl' as WebGL;
import 'dart:typed_data';
import 'dart:collection';
import 'package:vector_math/vector_math.dart';

part 'animation.dart';
part 'audio.dart';
part 'camera.dart';
part 'fsm.dart';
part 'ingame.dart';
part 'keyboard.dart';
part 'glHelpers.dart';
part 'objects.dart';
part 'scene.dart';
part 'shader.dart';
part 'texture.dart';


CanvasElement canvas;
WebGL.RenderingContext glContext;
AudioManager soundMgr;
TextureManager texMgr;
ShaderManager shaderMgr;
Application app;
CameraDirector camDirector;
FSM fsm;
Font font;

double scaleX = 1.0;
double scaleY = 1.0;
bool KONGREGATE_BUILD = false;

class Application
{
    Application()
    {       
        this._lastTime = 0.0;
        this._windowFocused = true;

        texMgr    = new TextureManager();        
        shaderMgr = new ShaderManager();
        soundMgr  = new AudioManager();
        camDirector = new CameraDirector();
        fsm = new FSM();
        fsm.SetState(States.LOADING);
        
        document.onMouseMove.listen(onMouseMove);
        document.onMouseDown.listen(onMouseDown);
        document.onMouseUp.listen(onMouseUp);
        document.onKeyDown.listen(onKeyDown);
        document.onKeyUp.listen(onKeyUp);
        window.onFocus.listen(onFocus);
        window.onBlur.listen(onBlur);
    }

    void OnStart()
    {
        glContext.clearColor(0.0, 0.0, 0.0, 1.0);
        glContext.enable(WebGL.RenderingContext.CULL_FACE);
        glContext.cullFace(WebGL.RenderingContext.FRONT);
        glContext.enable(WebGL.RenderingContext.BLEND);
        glContext.blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
        //glContext.enable(WebGL.RenderingContext.DEPTH_TEST);

        glContext.viewport(0, 0, canvas.width, canvas.height);
        glContext.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT | WebGL.RenderingContext.DEPTH_BUFFER_BIT);
            
        Tick();
    }

    void OnNewFrame(double time)
    {       
        num dt = time - _lastTime;
        
        if(dt < 50.0)
        {        
            fsm.OnNewFrame(dt);
        }
        
        _lastTime = time;
        
        Tick();
    }

    void Tick() 
    {
        window.requestAnimationFrame((num time) { OnNewFrame(time); });
    }

    void onMouseMove(MouseEvent event)
    {
        fsm.onMouseMove(event);        
    }

    void onMouseDown(MouseEvent event)
    {
        fsm.onMouseDown(event);     
    }

    void onMouseUp(MouseEvent event)
    {
        fsm.onMouseUp(event);        
    }

    void onKeyDown(KeyboardEvent event) 
    {
        KeyCode.keyPressed[event.keyCode] = true;
        
        fsm.onKeyDown(event);             
    }

    void onKeyUp(KeyboardEvent event) 
    {
        KeyCode.keyPressed[event.keyCode] = false;
        
        fsm.onKeyUp(event);
    }

    void onFocus(Event event)
    {
        this._windowFocused = true;              
        fsm.onFocus(event);
    }
    
    void onBlur(Event event)
    {
        this._windowFocused = false;
        fsm.onBlur(event);
    }    
    
    double _lastTime;
    bool _windowFocused;
}


void noWebGL() {    
    if(KONGREGATE_BUILD == false)
    {
        querySelector("#canvas_div").remove();
        final NodeValidatorBuilder _htmlValidator=new NodeValidatorBuilder.common()
        ..allowElement('a', attributes: ['href']);
        querySelector("#error_div").setInnerHtml('<pre>No WebGL support detected.\rPlease see <a href="http://get.webgl.org/">get.webgl.org</a>.</pre>', validator: _htmlValidator);
    }
}

void appCrashed(e) {
    querySelector("#canvas_div").remove();
    String message = new HtmlEscape().convert(e.toString());
    querySelector("#error_div").setInnerHtml("<pre>An error occured: \r\r$message</pre>");
}


void main() 
{
    canvas = document.getElementById("drawCanvas");
    
    scaleX = canvas.width / 1024.0;
    scaleY = canvas.height / 768.0;
    
    if(scaleX != 1.0 || scaleY != 1.0)
        KONGREGATE_BUILD = true;
    
    
    glContext = canvas.getContext("experimental-webgl");       
    
    if(glContext == null)
    {
        noWebGL();
        return;
    }
    
    try
    {
        app = new Application();
        app.OnStart();
    }
    catch(e)
    {
        appCrashed(e);
        rethrow;
    }
}
