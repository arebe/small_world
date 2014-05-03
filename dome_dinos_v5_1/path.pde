class Path {
  int x1, y1, x2, y2;
  PVector delta, ortho;

  Path(int pX, int pY) {
    x1 = pX;
    y1 = pY;
  }

  void update(int pX, int pY) {
    x2 = pX;
    y2 = pY;
    delta = new PVector(x2 - x1, y2 - y1);
    ortho = new PVector(-(y2 - y1), x2 - x1);
    // start new path
    x1 = pX;
    y1 = pY;
  }

  PVector getDelta() {
    return delta;
  }
  
  PVector getOrtho(){
    return ortho;
  }
  
}
