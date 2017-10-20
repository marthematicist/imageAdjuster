class SlideShow {
  int num;              // number of images
  File[] imageFiles;    // array of image File objects
  IntList fileOrder;    // order in which files will be displayed
  LoadImage LI;
  Thread LIthread;
  int counter;
  PImage currentImage;
  PImage nextImage;
  PGraphics buffer;
  int imageDuration = 999999999;
  int lastImageStartTime;
  int maxFileSize = 500000;
  int state = 0;            // 0 = loading ; 1 = waiting ; 2 = transitioning
  int stateEndTime;
  Boolean currentImageModified = false;
  Boolean rotateCommandFlag = false;
  Boolean nextImageTrigger = false;
  Boolean prevImageTrigger = false;
  float rotateCommandAng = 0;
  
  
  SlideShow( String path ) {
    buffer = createGraphics( width , height );
    ArrayList<File> allFiles = listFilesRecursive(path);
    ArrayList<File> imageList = new ArrayList<File>();
    String[] imageExtensions = { "jpg" , "png" , "gif" , "tga"  } ;
    for( File f : allFiles ) {
      String fileName = f.getName();
      int ind = fileName.lastIndexOf(".");
      if( ind != -1 ) {
        String ext = fileName.substring( ind+1 , fileName.length() );
        String name = fileName.substring( 0,ind );
        for( String e : imageExtensions ) {
          if( ext.compareToIgnoreCase( e ) == 0 ) {
            imageList.add( f );
            println( fileName , name , ext );
          }
        }
      }
    }
    
    num = imageList.size();
    fileOrder = new IntList(num);
    imageFiles = new File[num];
    for( int i = 0 ; i < num ; i++ ) {
      imageFiles[i] = imageList.get(i);
      fileOrder.set( i , i );
    }
    //shuffleOrder();
    counter = 0;
    
    String currentImagePath = imageFiles[fileOrder.get((counter)%num)].getAbsolutePath();
    currentImage = loadImage( currentImagePath );
    paintCurrentImage();
    stateEndTime = millis() + imageDuration;
    println( "starting" );
  }
  
  void draw() {
    int t = millis();
    
    if( rotateCommandFlag ) {
      rotateCommandFlag = false;
      rotateImage( rotateCommandAng );
      stateEndTime = t + imageDuration;
      paintCurrentImage();
    }
    
    if( t > stateEndTime || nextImageTrigger || prevImageTrigger ) {
      if( currentImageModified ) {
        currentImageModified = false;
        currentImage.save( imageFiles[fileOrder.get((counter)%num)].getAbsolutePath() );
      }
      if( prevImageTrigger ) {
        counter--;
        if( counter < 0 ) { counter = num -1; }
      }
      if( nextImageTrigger || t > stateEndTime ) {
        counter++;
        counter%=num;
      }
      nextImageTrigger = false;
      prevImageTrigger = false;
      String currentImagePath = imageFiles[fileOrder.get((counter)%num)].getAbsolutePath();
      currentImage = loadImage( currentImagePath );
      paintCurrentImage();
      stateEndTime = t + imageDuration;
    }
  }
  
  void paintCurrentImage() {
    buffer.beginDraw();
    buffer.background(0);
    int w = buffer.width;
    int h = buffer.height;
    float ar0 = float(w)/float(h);
    float ar1 = float(currentImage.width)/float(currentImage.height);
    float h1=0;
    float w1=0;
    if( currentImage.width<currentImage.height ) {
      h1 = h;
      w1 = h1*ar1;
      
    } else {
      if( ar0 > ar1 ) {
        h1 = h*1.0;
        w1 = h1*ar1*1.0;
      } else {
        
        w1 = w;
        h1 = w1/ar1;
      }
    }
    buffer.image(  currentImage , 0.5*w - 0.5*w1 , 0.5*h - 0.5*h1 , w1 , h1 );
    buffer.endDraw();
  }
  
  void rotateImage( float ang ) {
    if( ang == 180 ) {
      PGraphics buf = createGraphics( currentImage.width , currentImage.height );
      buf.beginDraw();
      buf.pushMatrix();
      buf.translate( 0.5*buf.width , 0.5*buf.height );
      buf.rotate( ang/180*PI );
      buf.translate( -0.5*buf.width , -0.5*buf.height );
      buf.image( currentImage , 0 , 0 );
      buf.popMatrix();
      buf.endDraw();
      currentImageModified = true;
      currentImage = buf;
    }
    if( ang == 90 || ang == -90 ) {
      PGraphics buf = createGraphics( currentImage.height , currentImage.width );
      buf.beginDraw();
      buf.pushMatrix();
      buf.translate(  0.5*buf.width , 0.5*buf.height );
      buf.rotate( ang/180*PI );
      buf.translate( -0.5*buf.height ,  -0.5*buf.width );
      buf.image( currentImage , 0 , 0 );
      buf.popMatrix();
      buf.endDraw();
      currentImageModified = true;
      currentImage = buf;
    }
  }
  
  void rotateImage90(float ang ) {
    
  }
  

  
  void shuffleOrder() {
    fileOrder.shuffle();
  }
  

  
  // lists all file names from a directory dir
  String[] listFileNames( String dir ) {
    File file = new File(dir);
    if( file.isDirectory() ) {
      String names[] = file.list();
      return names;
    } else {
      return null;
    }
  }
  
  // returns all files in a directory as an array of File objects
  File[] listFiles( String dir ) {
    File file = new File(dir);
    if( file.isDirectory() ) {
      File[] files = file.listFiles();
      return files;
    } else {
      return null;
    }
  }
  
  // traverses subdirectories
  void recurseDir( ArrayList<File> a , String dir ) {
    File file = new File(dir);
    if( file.isDirectory() ) {
      a.add( file );
      File[] subfiles = file.listFiles();
      for( int i = 0 ; i < subfiles.length ; i++ ) {
        recurseDir( a , subfiles[i].getAbsolutePath() );
      } 
    }else {
        a.add( file );
    }
  }
  
  // gets a list of all files int a directory and all subdirectories
  ArrayList<File> listFilesRecursive( String dir ) {
    ArrayList<File> fileList = new ArrayList<File>();
    recurseDir( fileList , dir );
    return fileList;
  }
  
  class LoadImage implements Runnable {
    String imagePath;
    boolean done;
    PImage img;
    int w;
    int h;
    
    LoadImage( String path , int wIn , int hIn ) {
      this.imagePath = path;
      this.w = wIn;
      this.h = hIn;
      this.done = true;
      img = createGraphics(w,h);
    }
    
    void run() {
      done = false;
      PImage raw = loadImage( imagePath );
      int w0 = w;
      int h0 = h;
      int w1 = raw.width;
      int h1 = raw.height;
      int maxDim0 = max( w0 , h0 );
      int minDim1 = min( w1 , h1 );
      float ar1 = float(raw.width)/float(raw.height);
      if( minDim1 > maxDim0 ) {
        if( w0 > h0 ) {
          if( w1 > h1 ) {
            raw.resize( ceil(w0) , ceil(w0/ar1) );
            
          } else {
            // h1 > w1
            raw.resize( ceil(w0/ar1) , ceil(w0) );
          }
        } else {
          // h0 > w0
          if( w1 > h1 ) {
            raw.resize( ceil(h0) , ceil(h0*ar1) );
          }  else {
            // h1 > w0
            raw.resize( ceil(h0*ar1) , ceil(h0) );
          }
        }
        //raw.save( imagePath );
        println("saving image");
      }
      img = raw;
      done = true;
    }
  }
    
  
}