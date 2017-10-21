String imagePath = "E:\\media\\forMom";
int xRes = 1920;
int yRes = 1080;
File[] imageFiles;
SlideShow Photos;
int num;
int phase = 0;
int counter = 0;
helpText help;

void settings() {
  fullScreen();
}

void setup() {
  size( 800,600 );
  imageFiles = getImageFiles( imagePath );
  counter = 0;
  help = new helpText(0.02*height);
}

File[] getImageFiles( String path ) {
  ArrayList<File> allFiles = listFilesRecursive(path);
  ArrayList<File> imageList = new ArrayList<File>();
  String[] imageExtensions = { "jpg" , "png" , "gif" , "tga" } ;
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
  File[] output = new File[num];
  for( int i = 0 ; i < num ; i++ ) {
    output[i] = imageList.get(i);
  }
  return output;
}


void draw() {
  if( phase == 0 ) {
    if( counter < num ) {
      long oldSize = imageFiles[counter].length();
      resizeImage( imageFiles[counter] , xRes , yRes );
      long newSize = imageFiles[counter].length();
      String outStr = "File " + (counter+1) + " of " + num + " resized from " + (oldSize/1000) + "kb to " + (newSize/1000) + "kb" ;
      println( "File " + (counter+1) + " of " + num + " resized from " + (oldSize/1000) + "kb to " + (newSize/1000) + "kb" );
      textAlign( CENTER , CENTER );
      textSize( 0.05*height );
      background(0);
      fill(255);
      text( outStr , 0.5*width , 0.5*height );
      counter++;
    } else { 
      phase = 1;
      imageFiles = getImageFiles( imagePath );
      Photos = new SlideShow( imagePath );
    }
  }
  if( phase == 1 ) {
    try {
      Photos.draw();
      image( Photos.buffer , 0 , 0 );
      image( help.buf, 0 , 0 );
      String dispText = "image " +(Photos.counter+1) + " of " + Photos.num ;
      float h = 0.02*height;
      textSize( h );
      textAlign( LEFT , TOP );
      float w = textWidth( dispText );
      fill( 0 , help.alpha );
      rect( width - w - 0.5*h , height - 1.25*h , w + 0.5*h , 1.25*h );
      fill( 255 );
      text( dispText ,  width - w - 0.5*h , height - 1.25*h );
      
    } catch( Exception e ) {
      println( e.getMessage() );
      exit();
    }
  }
}



void resizeImage( File f , int w , int h ) {
  String imagePath = f.getAbsolutePath();
  PImage raw = loadImage( imagePath );
  int w0 = w;
  int h0 = h;
  int w1 = raw.width;
  int h1 = raw.height;
  int maxDim0 = max( w0 , h0 );
  int minDim1 = min( w1 , h1 );
  float ar1 = float(raw.width)/float(raw.height);
  if( minDim1 > maxDim0 ) {
    
    if( w1 > h1 ) {
      raw.resize( ceil(w0) , ceil(w0/ar1) );
      println( w0 , h0 );
      
    } else {
      // h1 > w1
      raw.resize( ceil(w0*ar1) , ceil(w0) );
      println( w1 , h1 );
      println( ceil(w0*ar1) , ceil(w0) );
    }
    
    raw.save( imagePath );
    println("saving image");
  }
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

// gets a list of all files in a directory and all subdirectories
ArrayList<File> listFilesRecursive( String dir ) {
  ArrayList<File> fileList = new ArrayList<File>();
  recurseDir( fileList , dir );
  return fileList;
}

void keyPressed() {
  println( keyCode );
  if( keyCode == 37 ) {
    Photos.rotateCommandFlag = true;
    Photos.rotateCommandAng = -90;
  }
  if( keyCode == 39 ) {
    Photos.rotateCommandFlag = true;
    Photos.rotateCommandAng = 90;
  }
  if( keyCode == 40 || keyCode == 38 ) {
    Photos.rotateCommandFlag = true;
    Photos.rotateCommandAng = 180;
  }
  if( keyCode == 32 || keyCode == 46 ) {
    Photos.nextImageTrigger = true;
  }
  if( keyCode == 44 || keyCode == 8 ) {
    Photos.prevImageTrigger = true;
  }
}

class helpText {
  String[] helpString = { "next image - [.>] or [SPACE]" ,
                          "prev image - [,<] or [BACKSPACE]" , 
                          "rotate 90  - [ARROW_LEFT] or [ARROW_RIGHT]",
                          "rotate 180 - [ARROW_UP] or [arrow_DOWN]" , 
                          "exit app   - [ESC]"
                        };
  PGraphics buf;
  int alpha = 128;
  helpText( float tSize ) {
    textSize( tSize );
    float w = 0;
    for( int i = 0 ; i < helpString.length ; i++ ) {
      if( textWidth(helpString[i]) > w ) { w = textWidth(helpString[i]); }
    }
    float h = tSize*helpString.length+0.5*tSize;
    buf = createGraphics( ceil(w) , ceil(h) );
    buf.beginDraw();
    buf.fill( 0 , alpha );
    float a = 0.5;
    buf.rect( 0 , 0 , ceil(w) , ceil(h) , a*tSize , a*tSize , a*tSize , a*tSize );
    buf.fill( 255  );
    buf.textSize( tSize );
    for( int i = 0 ; i < helpString.length ; i++ ) {
      buf.text( helpString[i] , 0 , (i+1)*tSize );
    }
    buf.endDraw();
  }
}