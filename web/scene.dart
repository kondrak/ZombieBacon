part of zombiebacon;

Piglet sprite; 

class BurstParticle
{
    BurstParticle()
    {
        _position = new Vector2(0.0, 0.0);
        _velocity = new Vector2(0.0, 0.0);
    }
    
    double _decayX;
    double _decayY;
    double _alpha;
    Animation _particle;
    Vector2 _position;
    Vector2 _velocity; 
}

class BloodBurst
{
    List<BurstParticle> _particles;
    bool _running;
    Math.Random rng;
    double _timeLapse;
    Vector3 _position;
    
    BloodBurst()
    {
        _running = false;
        _timeLapse = 0.0;
        _position = new Vector3(0.0, 0.0, -1.0);
        rng = new Math.Random();
        _particles = new List<BurstParticle>();
        
        for (int i = 0; i < 96; ++i)
        {
            BurstParticle newParticle = new BurstParticle();
            newParticle._alpha = 1.0;
            newParticle._decayX = 1.0;
            newParticle._decayY = 1.0;
            newParticle._position = new Vector2(0.0, 0.0);
            newParticle._velocity.x = 0.01; //100.0 + rng.nextDouble() * 200.0;
            newParticle._velocity.y = 0.01; //-(100.0 + rng.nextDouble() * 200.0);            
            newParticle._particle = new Animation(new Vector3(0.0, 0.0, 0.0));
            newParticle._particle.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 8, 8, new Vector3(0.0, 0.0, 0.0), new Vector2(466.0, 177.0)), "atlasTex", 1000.0);
      
            //newParticle._particle.->SetRotationSpeed(0.01f);

            _particles.add(newParticle);
        }       
    }
    
    void OnNewFrame(double dt)
    {
        double delta = dt / 1000.0;
        if (!_running)
            return;

        _timeLapse += delta;            

        for (int i = 0; i < _particles.length; i++)
        {
            _particles[i]._position.x += _particles[i]._velocity.x * delta * 1.5;
            _particles[i]._position.y += _particles[i]._velocity.y * delta * 1.5;
            _particles[i]._velocity.y -= delta;
            _particles[i]._particle.animPosition = new Vector3(_position.x + _particles[i]._position.x, _position.y + _particles[i]._position.y, -1.0);
            _particles[i]._particle.OnNewFrame(dt);
        }

        _running = _timeLapse < 5.0;    
    }
    
    void Stop()
    {
        _running = false;        
    }
    
    void Restart()
    {
        _running = true;
        _timeLapse = 0.0;
        _position = sprite.animPosition;

        for (int i = 0; i < _particles.length; ++i)
        {
            _particles[i]._alpha = 1.0;
            _particles[i]._position = new Vector2(0.0, 0.0);

            _particles[i]._velocity.x = 0.2 + rng.nextDouble() * 0.5; 
            _particles[i]._velocity.y = 0.1 + rng.nextDouble() * (i + 1) * 0.5;

            _particles[i]._velocity.x *= 0.5;
            _particles[i]._velocity.y *= 0.5;

            if (i < _particles.length / 2)
                _particles[i]._velocity.x *= -1;
            else
            {
                _particles[i]._velocity.x = -_particles[i - _particles.length ~/ 2]._velocity.x;
                _particles[i]._velocity.y = _particles[i - _particles.length ~/ 2]._velocity.y;
            }
        }        
    }
}

double TOP_SCREEN = 0.0;
double BOTTOM_SCREEN = -2.0;
double LEFT_SCREEN = 0.0;
double RIGHT_SCREEN = 2.0 * camDirector.activeCamera._aspectRatio;    
double seconds = 0.0;
double miliseconds = 0.0;
double startupTimer = 0.0;
double lastScore = 0.0;
double personalBest = 0.0;
bool mainScreen = true;
bool isStartPosition = true;
bool baconActive = false;
int prevRank = 0;
bool blocksCollided = false; 
bool musicTogglePressed = false;
bool scoreSubmitted = false;

void SubmitKongregateScore(int score)
{
    if(!scoreSubmitted)
    {
        print("SENDING SCORE ");
        print(score);
        print("SENDING SCORE DONE");
    }
    
    scoreSubmitted = true;
}

class Block extends Animation
{
    Vector3 startPosition;
    
    Block(animPos) : super(animPos)
    {
        startPosition = new Vector3(animPos.x, animPos.y, animPos.z);
    }

    void Reset()
    {
        this.animPosition.xy = startPosition.xy;
    }
    
    double GetLeftEdge()
    {
        return this.animPosition.x - 2 * scaleX * this.animPivot.x * camDirector.activeCamera._aspectRatio * this.frames[this._currentFrame].frameData.width / canvas.width;
    }
    
    double GetRightEdge()
    {
        return this.animPosition.x - this.animPivot.x * 2 * scaleX * camDirector.activeCamera._aspectRatio * this.frames[this._currentFrame].frameData.width / canvas.width + 2 * camDirector.activeCamera._aspectRatio * scaleX * this.frames[this._currentFrame].frameData.width / canvas.width;
    }    
    
    double GetBottomEdge()
    {
        return this.animPosition.y + this.animPivot.y * 2 * scaleY * this.frames[this._currentFrame].frameData.height / canvas.height - 2 * scaleY * this.frames[this._currentFrame].frameData.height / canvas.height;
    }
    
    double GetTopEdge()
    {
        return this.animPosition.y + 2 * scaleY * this.animPivot.y * this.frames[this._currentFrame].frameData.height / canvas.height;
    }     
    
    bool Intersects(Block other)
    {
        if(GetLeftEdge() >= other.GetRightEdge() || 
           GetRightEdge() <= other.GetLeftEdge() ||
           GetTopEdge() <= other.GetBottomEdge() ||
           GetBottomEdge() >= other.GetTopEdge())
        return false;
        
        return true;
    }
    
    bool IntersectsHacked(Block other)
    {
        if((GetLeftEdge()+ 0.03) >= other.GetRightEdge() || 
           (GetRightEdge() + 0.02) <= other.GetLeftEdge() ||
           (GetTopEdge() - 0.02) <= other.GetBottomEdge() ||
           (GetBottomEdge()- 0.02) >= other.GetTopEdge())
        return false;
        
        return true;
    }    
}

class Piglet extends Block
{
    double velocity = -0.45;
    bool visible = true;
    Piglet(animPos) : super(animPos);    
    
    void OnNewFrame(double dt)
    {
        if(!visible)
            return;
        
        if(mainScreen)
        {
            this.animPosition.x += dt * velocity / 1000.0;
            
            num left = this.animPosition.x - 2 * this.animPivot.x * camDirector.activeCamera._aspectRatio * 280.0 / canvas.width;
            num right = this.animPosition.x - this.animPivot.x * 2 * camDirector.activeCamera._aspectRatio * 280.0 / canvas.width + 2 * camDirector.activeCamera._aspectRatio * 280.0 / canvas.width;
            
            if(left <= LEFT_SCREEN)
            {
                this.animPosition.x -= left;
                velocity = 0.45;
            }
            
            if(right >= RIGHT_SCREEN)
            {
                this.animPosition.x += RIGHT_SCREEN - right;
                velocity = -0.45;            
            }               
        }
        
        super.OnNewFrame(dt);
    }
    
    void OnDeath()
    {
        this.visible = false;
        soundMgr.Toggle('death', false);
    }
    
    void Reset()
    {
        super.Reset();
        this.visible = true;
    }
}

class MovingBlock extends Block
{
    Vector2 travelPath;
    double velocity;
    List<double> angles;
    Math.Random rng;

    MovingBlock(animPos) : super(animPos)
    {
        angles = new List<double>();
        angles.add(3.1415 / 4.0);
        angles.add(3.0 * 3.1415 / 4.0);
        angles.add(3.1415);
        rng = new Math.Random();
        travelPath = GL.RotateVector(new Vector2(0.0, 1.0), angles[rng.nextInt(3)]);
        velocity = 0.3;
    }
    
    void Reset()
    {
        super.Reset();
        
        travelPath = GL.RotateVector(new Vector2(0.0, 1.0), angles[rng.nextInt(3)]);
        velocity = 0.5;
    }
    
    void OnNewFrame(double dt)
    {
        super.OnNewFrame(dt);

        if(baconActive)
        {
            this.animPosition.x += dt * (travelPath * velocity).x / 1000.0;
            this.animPosition.y += dt * (travelPath * velocity).y / 1000.0;
            
            if(GetBottomEdge() <= BOTTOM_SCREEN)
            {
                this.animPosition.y += BOTTOM_SCREEN - GetBottomEdge();
                travelPath = GL.RotateVector(travelPath, (rng.nextDouble() + 0.6) * 3 * 3.1415 / 4.0);
                velocity += 0.1;
            }
            
            if(GetTopEdge() >= TOP_SCREEN)
            {
                this.animPosition.y += TOP_SCREEN - GetTopEdge();
                travelPath = GL.RotateVector(travelPath, (rng.nextDouble() + 0.6) * 3.1415 / 4.0);  
                velocity += 0.1;
            }
            
            if(GetLeftEdge() <= LEFT_SCREEN)
            {
                this.animPosition.x -= GetLeftEdge();
                travelPath = GL.RotateVector(travelPath, (rng.nextDouble() + 0.6) * 3.1415 / 4.0);
                velocity += 0.05;
            }
            
            if(GetRightEdge() >= RIGHT_SCREEN)
            {
                this.animPosition.x += RIGHT_SCREEN - GetRightEdge();
                travelPath = GL.RotateVector(travelPath, (rng.nextDouble() + 0.6) * 3.1415 / 4.0); 
                velocity += 0.07;                         
            }
            
        }
        else if(mainScreen)
        {
            this.animPosition.x += dt * velocity / 1000.0;
            
            num left = this.animPosition.x - 2 * this.animPivot.x * camDirector.activeCamera._aspectRatio * 280.0 / canvas.width;
            num right = this.animPosition.x - this.animPivot.x * 2 * camDirector.activeCamera._aspectRatio * 280.0 / canvas.width + 2 * camDirector.activeCamera._aspectRatio * 280.0 / canvas.width;
            
            if(left <= LEFT_SCREEN)
            {
                this.animPosition.x -= left;
                velocity = 0.45;
            }
            
            if(right >= RIGHT_SCREEN)
            {
                this.animPosition.x += RIGHT_SCREEN - right;
                velocity = -0.45;            
            }            
        }               
        
        if(velocity > 2.5)
            velocity = 2.5;
    }
}

class Scene
{
    List<Block> borders;
    List<MovingBlock> enemies;
    List<Animation> _bloodSplats;
    Animation spriteMad;
    Animation spriteZombie;
    Animation spriteBacon;
    Animation spriteAttack;
    Animation transBg;
    Animation sndOn;
    Animation sndOff;
    Math.Random rng;
  
    Font startText; 
    Font link;
    Font credits; 
    Font clickToStart;
    Font newPersonalBest;
    Font surviveTime;
    Font yourRank;
    Font rankName;
    Font nextGoal;
 
    bool personalBestBeaten;
    bool _flameClicked;
    Vector2 _clickOffset;
    
    BloodBurst _bloodBurst;
    
    Scene([this._flameClicked = false]);
    
    void Load()
    {        
        rng = new Math.Random();
        enemies = new List<MovingBlock>();
        sprite = new Piglet(new Vector3(1.0 * camDirector.activeCamera._aspectRatio, -1.0, 0.0));
        sprite.animPivot = new Vector2(0.5, 0.5);
        sprite.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 65, 64, new Vector3(0.0, 0.0, 0.0), new Vector2(729.0, 1.0)), "atlasTex", 250.0);
        sprite.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 65, 64, new Vector3(0.0, 0.0, 0.0), new Vector2(796.0, 1.0)), "atlasTex", 250.0);
        sprite.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 65, 64, new Vector3(0.0, 0.0, 0.0), new Vector2(863.0, 1.0)), "atlasTex", 250.0);
        sprite.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 65, 64, new Vector3(0.0, 0.0, 0.0), new Vector2(930.0, 1.0)), "atlasTex", 250.0);

        spriteMad = new Animation(new Vector3(0.63 * camDirector.activeCamera._aspectRatio, -0.25, 0.0));
        spriteMad.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 435, 99, new Vector3(0.0, 0.0, 0.0), new Vector2(541.0, 109.0)), "atlasTex", 1000.0);
  
        spriteZombie = new Animation(new Vector3(0.63 * camDirector.activeCamera._aspectRatio, -0.52, 0.0));
        spriteZombie.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 422, 61, new Vector3(0.0, 0.0, 0.0), new Vector2(212.0, 442.0)), "atlasTex", 1000.0);        
        
        spriteBacon = new Animation(new Vector3(0.41 * camDirector.activeCamera._aspectRatio, -0.65, 0.0));
        spriteBacon.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 625, 127, new Vector3(0.0, 0.0, 0.0), new Vector2(169.0, 210.0)), "atlasTex", 1000.0);
 
        spriteAttack = new Animation(new Vector3(0.59 * camDirector.activeCamera._aspectRatio, -1.00, 0.0));
        spriteAttack.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 448, 61, new Vector3(0.0, 0.0, 0.0), new Vector2(211.0, 521.0)), "atlasTex", 1000.0);
        
        
        transBg = new Animation(new Vector3(0.55 * scaleX * camDirector.activeCamera._aspectRatio, -0.68 * scaleY, 0.0));
        transBg.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 32, 32, new Vector3(0.0, 0.0, 0.0), new Vector2(466.0, 139.0)), "atlasTex", 1000.0);
        transBg.animScale.x = 15.5;   
        transBg.animScale.y = 10.0;
    
        sndOn = new Animation(new Vector3(1.89 * camDirector.activeCamera._aspectRatio, -0.05, 0.0));
        sndOn.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 46, 37, new Vector3(0.0, 0.0, 0.0), new Vector2(526.0, 351.0)), "atlasTex", 1000.0);
        //transBg.animScale.x = 15.5;   
        //transBg.animScale.y = 7.0;        
     
        sndOff = new Animation(new Vector3(1.89 * camDirector.activeCamera._aspectRatio, -0.05, 0.0));
        sndOff.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 46, 37, new Vector3(0.0, 0.0, 0.0), new Vector2(585.0, 351.0)), "atlasTex", 1000.0);
        
        
        MovingBlock b1 = new MovingBlock(new Vector3(0.5 * camDirector.activeCamera._aspectRatio, -0.6, 0.0));
        b1.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 145, 48, new Vector3(0.0, 0.0, 0.0), new Vector2(163.0, 148.0)), "atlasTex", 500.0);
        b1.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 145, 48, new Vector3(0.0, 0.0, 0.0), new Vector2(310.0, 148.0)), "atlasTex", 500.0);
       
        MovingBlock b2 = new MovingBlock(new Vector3(1.45 * camDirector.activeCamera._aspectRatio, -1.45, 0.0));
        b2.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 49, 145, new Vector3(0.0, 0.0, 0.0), new Vector2(163.0, 1.0)), "atlasTex", 500.0);
        b2.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 49, 145, new Vector3(0.0, 0.0, 0.0), new Vector2(214.0, 1.0)), "atlasTex", 500.0);
        
        MovingBlock b3 = new MovingBlock(new Vector3(1.35 * camDirector.activeCamera._aspectRatio, -0.55, 0.0));
        b3.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 98, 97, new Vector3(0.0, 0.0, 0.0), new Vector2(529.0, 1.0)), "atlasTex", 500.0);
        b3.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 98, 97, new Vector3(0.0, 0.0, 0.0), new Vector2(629.0, 1.0)), "atlasTex", 500.0);
        
        MovingBlock b4 = new MovingBlock(new Vector3(0.6 * camDirector.activeCamera._aspectRatio, -1.6, 0.0));
        b4.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 130, 128, new Vector3(0.0, 0.0, 0.0), new Vector2(265.0, 1.0)), "atlasTex", 500.0);
        b4.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 130, 128, new Vector3(0.0, 0.0, 0.0), new Vector2(397.0, 1.0)), "atlasTex", 500.0);
             
        
        enemies.add(b1);        
        enemies.add(b3);
        enemies.add(b4);
        enemies.add(b2);
        
        for(int i = 0; i < enemies.length; i++)
        {
            enemies[i].animPivot = new Vector2(0.5, 0.5);
        }
        
        startText = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-2.90, -6.0, -1.0));
        startText.scale = new Vector3(2.0 * scaleX, 2.0 * scaleY, 1.0);
        startText.fixedPos = true;           

        if(KONGREGATE_BUILD)
            credits = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-9.35, -7.75, -1.0));
        else
            credits = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-9.35, -7.95, -1.0));
        credits.scale = new Vector3(2.0 * scaleX, 2.0 * scaleY, 1.0);
        credits.fixedPos = true;           
          
        link = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-2.35, -8.4, -1.0));
        link.scale = new Vector3(2.0 * scaleX, 2.0 * scaleY, 1.0);
        link.fixedPos = true;         
        
        if(KONGREGATE_BUILD)
            clickToStart = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-4.15, -1.15, -1.0));
        else
            clickToStart = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-3.25, -1.15, -1.0));
        
        clickToStart.scale = new Vector3(2.0, 2.0, 1.0);
        clickToStart.fixedPos = true;         
  
        newPersonalBest = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-2.55, 2.35 / scaleY, -1.0));
        newPersonalBest.scale = new Vector3(4.0, 4.0, 1.0);
        newPersonalBest.fixedPos = true;          
        
        surviveTime = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-1.35, 1.18  / scaleY, -1.0));
        surviveTime.scale = new Vector3(4.0, 4.0, 1.0);
        surviveTime.fixedPos = true;         
        
        yourRank = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-0.60, -0.40, -1.0));
        yourRank.scale = new Vector3(3.0, 3.0, 1.0);
        yourRank.fixedPos = true;          
  
        rankName = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-1.45, -1.25, -1.0));
        rankName.scale = new Vector3(3.0, 3.0, 1.0);
        rankName.fixedPos = true;           
        
        if(KONGREGATE_BUILD)
            nextGoal = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-3.25 / scaleX, -3.05 / scaleY, -1.0));
        else
            nextGoal = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-3.25 / scaleX, -3.55 / scaleY, -1.0));
        
        nextGoal.scale = new Vector3(2.5, 2.5, 1.0);
        nextGoal.fixedPos = true;          
        
        // left
        borders = new List<Block>();
        borders.add(new Block(new Vector3(0.0, 0.0, 0.0)));
        borders.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 80, 768, new Vector3(0.0, 0.0, 0.0), new Vector2(1.0, 1.0)), "atlasTex", 5000.0);
                
        // top
        borders.add(new Block(new Vector3(80.0 * scaleX * 2 * camDirector.activeCamera._aspectRatio / canvas.width, 0.0, 0.0)));       
        borders.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 865, 76, new Vector3(0.0, 0.0, 0.0), new Vector2(1.0, 848.0)), "atlasTex", 5000.0);
                
        // right    
        borders.add(new Block(new Vector3((2 * (canvas.width - 80 * scaleX) * camDirector.activeCamera._aspectRatio) / canvas.width, 0.0, 0.0)));       
        borders.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 80, 768, new Vector3(0.0, 0.0, 0.0), new Vector2(82.0, 1.0)), "atlasTex", 5000.0);
                      
        // bottom
        borders.add(new Block(new Vector3( 2 * 80.0 * scaleX * camDirector.activeCamera._aspectRatio / canvas.width, -2 *( canvas.height - 80 * scaleY) / canvas.height, 0.0)));        
        borders.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 865, 80, new Vector3(0.0, 0.0, 0.0), new Vector2(1.0, 770.0)), "atlasTex", 5000.0);
        
        _clickOffset = new Vector2(0.0, 0.0);
        
        sprite.animPosition = new Vector3( -0.75 + camDirector.activeCamera._aspectRatio, -1.40, 0.0);
        
        for(int i = 0; i < enemies.length; i++)
        {
            enemies[i].animPosition = new Vector3(0.65 + camDirector.activeCamera._aspectRatio * (i + 1) * 0.26, -1.40, 0.0);
            enemies[i].velocity = -0.45;
        }        
        
        personalBestBeaten = false;
        
        _bloodBurst = new BloodBurst();
        
        _bloodSplats = new List<Animation>();  
    }

    void OnNewFrame(double dt)
    {
        seconds += dt / 1000.0;       
        miliseconds += dt / 250.0;   
        startupTimer += dt / 250.0;
        
        for(int i = 0; i < borders.length; i++)
        {
            GL.PushMatrix();
            borders[i].OnNewFrame(dt);
            
            bool colCheck = false;
            
            if(KONGREGATE_BUILD)
                colCheck = borders[i].IntersectsHacked(sprite);
            else
                colCheck = borders[i].Intersects(sprite);
            
            if(!blocksCollided && !mainScreen && colCheck)
            {
                blocksCollided = true;
                OnDeath();                
            }
            
            GL.PopMatrix();
        }
        
        GL.PushMatrix();
        for(int i = 0; i < _bloodSplats.length; i++)
        {
            _bloodSplats[i].OnNewFrame(dt);
        }        
        GL.PopMatrix();
        
        for(int i = 0; i < enemies.length; i++)
        {           
            GL.PushMatrix();                        
            enemies[i].OnNewFrame(dt);
            if(!blocksCollided && !mainScreen && enemies[i].Intersects(sprite))
            {
                blocksCollided = true;
                OnDeath();                
            }
            
            GL.PopMatrix();
        }
        
        GL.PushMatrix();
        sprite.OnNewFrame(dt);   
        if(mainScreen)
        {
            if(startupTimer > 0.5)
                spriteMad.OnNewFrame(dt);
            
            if(startupTimer > 2.5)
                spriteZombie.OnNewFrame(dt);
            
            if(startupTimer > 4.5)
                spriteBacon.OnNewFrame(dt);
            
            if(startupTimer > 6.5)
                spriteAttack.OnNewFrame(dt);
            
            
        }
        GL.PopMatrix();       
        
        GL.PushMatrix();
        _bloodBurst.OnNewFrame(dt);
        GL.PopMatrix();
        
        camDirector.activeCamera.SetMode(CameraMode.ORTHO);
        GL.PushMatrix();                 
        
        if(!mainScreen)
        {
            if(baconActive)
            {
                font.drawText( "Time: " + seconds.toStringAsFixed(2) + "s", new Vector4(1.0, 1.0, 1.0, 1.0));
                
                if(seconds > personalBest)
                {
                    personalBestBeaten = true;
                    personalBest = seconds;
                }
            }
            else
            {
                if(isStartPosition)
                    clickToStart.drawText("Drag PIGLET to START!", new Vector4(1.0, 1.0, 1.0, 1.0));
                else
                {               
                    transBg.OnNewFrame(dt);
                    if(personalBestBeaten)
                    {
                        newPersonalBest.position.x = -4.15 / scaleX;
                        if(miliseconds.toInt() % 2 == 0)
                            newPersonalBest.drawText("New Highscore!", new Vector4(1.0, 1.0, 1.0, 1.0));
                        else
                            newPersonalBest.drawText("New Highscore!", new Vector4(1.0, 0.0, 0.0, 1.0));
                        
                        if(personalBest >= 10.0)
                            surviveTime.position.x = -1.65 / scaleX;
                        else
                            surviveTime.position.x = -1.35 / scaleX;
                        
                        surviveTime.drawText(personalBest.toStringAsFixed(2) + "s", new Vector4(1.0, 1.0, 0.0, 1.0));
                        
                        SubmitKongregateScore((personalBest * 100).toInt());
                        
                        if(RankUpgrade())
                        {
                            yourRank.position.x = -1.95 / scaleX;
                            if(miliseconds.toInt() % 2 == 0)
                                yourRank.drawText("New Rank!", new Vector4(1.0, 1.0, 1.0, 1.0));
                            else
                                yourRank.drawText("New Rank!", new Vector4(1.0, 0.0, 0.0, 1.0));                           
                        }
                        else
                        {
                            yourRank.position.x = -0.95 / scaleX;
                            yourRank.drawText("Rank:", new Vector4(1.0, 1.0, 1.0, 1.0));
                        }
                        
                        DrawRank();                      
                    }
                    else if(personalBest > 0.0)
                    {                        
                        newPersonalBest.position.x = -4.55 / scaleX;
                        newPersonalBest.drawText(" You survived:", new Vector4(1.0, 1.0, 1.0, 1.0));
                        
                        if(personalBest >= 10.0)
                            surviveTime.position.x = -1.65 / scaleX;
                        else
                            surviveTime.position.x = -1.30 / scaleX;
                        
                        surviveTime.drawText(lastScore.toStringAsFixed(2) + "s", new Vector4(1.0, 1.0, 0.0, 1.0));
                    
                        yourRank.position.x = -0.95 / scaleX;
                        yourRank.drawText("Rank:", new Vector4(1.0, 1.0, 1.0, 1.0));
                        
                        DrawRank();                 
                    }   
                }
            }            
        }        
        else
        {
            if(seconds.toInt() % 2 == 0)
                startText.drawText("PRESS FIRE FOR PORK!", new Vector4(1.0, 1.0, 1.0, 1.0));           
            
            if(KONGREGATE_BUILD)
            {
                if(miliseconds.toInt() % 2 == 0)
                    link.drawText("Visit Home Page!", new Vector4(1.0, 0.0, 0.0, 1.0));
                else
                    link.drawText("Visit Home Page!", new Vector4(1.0, 1.0, 1.0, 1.0));
            }
            
            credits.drawText("2014 Krzysztof Kondrak, Lyrics and Music (c) Gerry Clark", new Vector4(1.0, 1.0, 1.0, 1.0));
        }              
        
        if(soundMgr.soundEnabled)
            sndOn.OnNewFrame(dt);
        else
            sndOff.OnNewFrame(dt);
        
        GL.PopMatrix();             

        if(!blocksCollided)
        {
            if(sprite.GetLeftEdge() < LEFT_SCREEN ||
               sprite.GetRightEdge() > RIGHT_SCREEN ||
               sprite.GetTopEdge() > TOP_SCREEN ||
               sprite.GetBottomEdge() < BOTTOM_SCREEN)
            {
                blocksCollided = true;
                OnDeath();
                
            }
        }
        
        if(blocksCollided)
        {
            if(baconActive)
                lastScore = seconds;
            
            seconds = 0.0;
            this.onMouseUp(new MouseEvent("release"));
            baconActive = false;
        }                
    }

    bool RankUpgrade()
    {
        num currentRank = 0;
        
        if(personalBest > 85.0)
        {
            currentRank++;
        }        
        
        if(personalBest > 60.0)
        {
            currentRank++;
        }
        
        if(personalBest > 45.0)
        {
            currentRank++;
        }
        
        if(personalBest > 30.0)
        {
            currentRank++;
        }
        
        if(personalBest > 20.0)
        {
            currentRank++;
        }
        
        if(personalBest > 10.0)
        {
            currentRank++;
        }
        
        if(personalBest > 5.0)
        {
            currentRank++;
        }      
        
       bool retVal = currentRank > prevRank;      
       
       return retVal;
    }
    
    void DrawRank()
    {
        List<String> ranks = new List<String>();
        
        ranks.add("Bacon Padawan");
        ranks.add("Pork-Fu Adept");
        ranks.add("Porkie Chan");        
        ranks.add("Piglet Princess");
        ranks.add("Porkspawn!");
        ranks.add("Bacon Demigod");
        ranks.add("GOD");
        ranks.add("INSANE!");
        
        String nextTime = "10.0s!";
        
        if(personalBest > 85.0)
        {
            rankName.position.x = -1.50 / scaleX;
            rankName.drawText(ranks[7], new Vector4(1.0, 0.0, 0.0, 1.0));
            nextTime ="INFINITY";
        }        
        else if(personalBest > 60.0)
        {
            rankName.position.x = -0.65 / scaleX;
            rankName.drawText(ranks[6], new Vector4(1.0, 1.0, 0.0, 1.0));
            nextTime = "85.0s!";
        }
        else if(personalBest > 45.0)
        {
            rankName.position.x = -2.95 / scaleX;;
            rankName.drawText(ranks[5], new Vector4(1.0, 1.0, 0.0, 1.0));
            nextTime = "60.0s!";
        }
        else if(personalBest > 30.0)
        {
            rankName.position.x = -2.25 / scaleX;;
            rankName.drawText(ranks[4], new Vector4(1.0, 1.0, 0.0, 1.0));
            nextTime = "45.0s!";
        }
        else if(personalBest > 20.0)
        {
            rankName.position.x = -3.50 / scaleX;;
            rankName.drawText(ranks[3], new Vector4(1.0, 1.0, 0.0, 1.0));
            nextTime = "30.0s!";
        }
        else if(personalBest > 15.0)
        {
            rankName.position.x = -2.50 / scaleX;;
            rankName.drawText(ranks[2], new Vector4(1.0, 1.0, 0.0, 1.0));
            nextTime = "20.0s!";
        }
        else if(personalBest > 10.0)
        {
            rankName.position.x = -2.95 / scaleX;;
            rankName.drawText(ranks[1], new Vector4(1.0, 1.0, 0.0, 1.0));
            nextTime = "15.0s!";
        }
        else
        {
            rankName.position.x = -2.95 / scaleX;;
            rankName.drawText(ranks[0], new Vector4(1.0, 1.0, 0.0, 1.0));
        }
        
        nextGoal.drawText("Next Goal: " + nextTime,new Vector4(1.0, 1.0, 1.0, 1.0));
    }
    
    void OnDeath()
    {
        sprite.OnDeath();
        _bloodBurst.Restart();
                
        if(_bloodSplats.length > 32)
            _bloodSplats.removeAt(0);
        
        _bloodSplats.add(new Animation(new Vector3(sprite.animPosition.x, sprite.animPosition.y, sprite.animPosition.z)));
        
         num rand = rng.nextInt(4);
        
         switch(rand)
         {
            case 0:
            _bloodSplats.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 72, 72, new Vector3(0.0, 0.0, 0.0), new Vector2(174.0, 352.0)), "atlasTex", 5000.0);
            break;
            case 1:
            _bloodSplats.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 64, 64, new Vector3(0.0, 0.0, 0.0), new Vector2(241.0, 348.0)), "atlasTex", 5000.0);
            break;
            case 2:
            _bloodSplats.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 96, 96, new Vector3(0.0, 0.0, 0.0), new Vector2(307.0, 341.0)), "atlasTex", 5000.0);
            break;
            case 3:
            _bloodSplats.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 96, 96, new Vector3(0.0, 0.0, 0.0), new Vector2(411.0, 341.0)), "atlasTex", 5000.0);
            break;            
            default:
            _bloodSplats.last.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 96, 96, new Vector3(0.0, 0.0, 0.0), new Vector2(307.0, 341.0)), "atlasTex", 5000.0);
            break;
         }
        _bloodSplats.last.animPivot = new Vector2(0.5, 0.5);        
    }
    
    void onMouseDown(MouseEvent event)
    {        
        var r = camDirector.activeCamera._aspectRatio;
        Vector2 clickPosition = new Vector2(2 * r * event.offset.x / canvas.width, -2 * event.offset.y / canvas.height);
        
        //toggle sound
        if(clickPosition.x >= 2.5 && clickPosition.y >= -0.15)
        {
            musicTogglePressed = true;
            return;
        }        

        if(mainScreen)
        {
            if(KONGREGATE_BUILD && clickPosition.y < -1.8)
            {
                window.open("http://kondrak.info", "Mad Zombie Bacon Attack!");
            }
            return;
        }
        
        if(!baconActive && !isStartPosition)
        {
            for(int i = 0; i < enemies.length; i++)
            {  
                enemies[i].Reset();
            }
            
            sprite.Reset();
            _bloodBurst.Stop();
            isStartPosition = true;
            blocksCollided = false;
            scoreSubmitted = false;
            
            
            num currentRank = 0;
         
            if(personalBest > 85.0)
            {
                currentRank++;
            }            
            
            if(personalBest > 60.0)
            {
                currentRank++;
            }
            
            if(personalBest > 45.0)
            {
                currentRank++;
            }
            
            if(personalBest > 30.0)
            {
                currentRank++;
            }
            
            if(personalBest > 20.0)
            {
                currentRank++;
            }
            
            if(personalBest > 15.0)
            {
                currentRank++;
            }
            
            if(personalBest > 10.0)
            {
                currentRank++;
            }  
            
            prevRank = currentRank;
            
            return;
        }
        
        if(!baconActive)
        {
            seconds = 0.0;
            personalBestBeaten = false;
            soundMgr.Toggle('start', false);
        }
        
        baconActive = true;
        isStartPosition = false;        
        
        Vector2 flamePos = new Vector2(sprite.animPosition.x, sprite.animPosition.y);
        
        if(clickPosition.x < sprite.GetLeftEdge() || 
           clickPosition.y > sprite.GetTopEdge() || 
           clickPosition.x > sprite.GetRightEdge()  || 
           clickPosition.y < sprite.GetBottomEdge())
            return;
        
        _clickOffset = flamePos - clickPosition;
        
        _flameClicked = true;        
    }
    
    void onMouseMove(MouseEvent event)
    {
        if(_flameClicked)
        {
            var r = camDirector.activeCamera._aspectRatio;
            sprite.animPosition = new Vector3(_clickOffset.x + 2 * r * event.offset.x / canvas.width, 
                                              _clickOffset.y - 2 * event.offset.y / canvas.height,
                                              sprite.animPosition.z);
        }
    }
    
    void onMouseUp(MouseEvent event)
    {
        if(musicTogglePressed)
        {
            soundMgr.soundEnabled = !soundMgr.soundEnabled;
                       
            if(soundMgr.soundEnabled)
            {
                if(musicTimer >= 3.1)
                    soundMgr.Play('music', true);
            }
            else
                soundMgr.Stop('music');
       
            musicTogglePressed = false;
            return;
        }
       
        
        if(mainScreen)
        {
            for(int i = 0; i < enemies.length; i++)
            {  
                enemies[i].Reset();
            }
            
            sprite.Reset();
            seconds = 0.0;
        }
                        
        _flameClicked = false;
        mainScreen = false;
    }
}
