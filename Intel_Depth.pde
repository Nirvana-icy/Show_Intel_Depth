import intel.pcsdk.*; //import the Intel Perceptual Computing SDK

int[] depth_size = new int[2];
short[] depthMap;
PImage depthImage;

PXCUPipeline session;

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.DEPTH_QVGA);

  //SETUP DEPTH MAP
  if(session.QueryDepthMapSize(depth_size))
  {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }
}

void draw()
{ 
  if (session.AcquireFrame(false))
  {
    session.QueryDepthMap(depthMap);   
    
    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++)
    {
      depthImage.pixels[i] = color(map(depthMap[i], 0, 32001, 0, 255));
    }
    depthImage.updatePixels();
    session.ReleaseFrame();//VERY IMPORTANT TO RELEASE THE FRAME    
  }
  image(depthImage, 0, 0, 640, 480);
}

void keyPressed() {
  println("pressed " + int(key) + " " + keyCode);
  if(keyCode == 83)
  {
    saveFrameToDisk();
  }
}


void saveFrameToDisk()
{
  //Get the current time 
  int yy = year();
  int mm = month();
  int dd = day();
  int hh = hour();
  int mi = minute();
  int ss = second();
  String Time = "Depth_" + yy + mm + dd + hh + mi + ss;
  //Write the depthMap[] to CSV Table
  Table table = new Table();
  //Write the first row  
  for(int i = 0; i < depth_size[0]; i++)
  {
      table.addColumn(i +"");
  }
  //Write the other row
  for(int RowNum = 0; RowNum < depth_size[1]; RowNum ++)
  {
    TableRow newRow = table.addRow();
    for(int i = 0; i < depth_size[0]; i++)
    {
      newRow.setInt(i +"", depthMap[RowNum*depth_size[0] + i]);
    }
  } 
  //Save the Table to the disk
  saveTable(table, Time + ".csv" );
}


