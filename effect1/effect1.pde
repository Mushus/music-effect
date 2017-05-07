import ddf.minim.analysis.*;
import ddf.minim.*;

// -----------------------------------------------------------------------------

// mp3ファイル
static String mp3file = "sample.mp3";
// mp3のサンプリングレート
static int samplingRate = 44100;

// フレームレート
static int frameRate = 60;
// 解析用のサンプリングレート(60fpsのときは512が最適)
static int fftSize = 512;

// 中央の画像
static String logofile = "logo.png";
// 画像の位置(x,y 正規化された値 0.5が中央)
static float[] logoPos = {0.5, 0.5};
// 画像の支点座標(x,y 正規化された値 0.5が中央)
static float[] logoOpos = {0.5, 0.75};
// 画像がどれくらい回転するか
static float logoAmplitude = 0.2;

// -- 波形 --
// 線の太さ
static int waveWeight = 4;
// 線の色(rgb値、0.0 ~ 1.0)
static float[] waveColor = {1, 1, 1};
// ボーリュームの大きさ(数字が大きいほど大きい方に偏る)
static float waveVolume = 5;

// -- 歪み --
// 位置(x,y 0.0 ~ 1.0)
static float[] shockwaveOpos = {0.5, 0.5};
// サイズ
static float shockwaveSize = 1;

// -- グラデーション --
// 濃い色
static float[] deepColor = {0, 0.05, 0.1};
// 薄い色
static float[] liteColor = {0, 0.7, 1};

// 残像(0.0 ~ 1.0で1が残像無し)
static float afterimageAlpha = 0.5;

// どれくらい間引くか
static int waveInterval = 3;
//フレームを出力するか
static boolean outputFrame = false;

// -----------------------------------------------------------------------------

PShader sw, grad;
PGraphics pg;
PImage pimg;

static int SPECTRA_LEFT = 0;
static int SPECTRA_RIGHT = 1;
static int SPECTRA_DIRECTION = 2;

// 解析結果、時間・方向・周波数の配列
float[][][] spectra;
int frame = 0;

// 初期化ルーチン
void setup() {
  size(1280, 720, P2D);
  background(0);
  if (outputFrame) {
    // 書き出すときは待つ必要ないのでそれなりの大きさにしておく
    frameRate(1000);
  } else {
    frameRate(frameRate);
  }

  analyzeMusic(mp3file);

  pg = createGraphics(width, height, P2D);

  pimg = loadImage(logofile);

  sw = loadShader("shockwave.glsl");
  sw.set("ratio", float(width) / float(height));
  sw.set("size", shockwaveSize);
  sw.set("opos", shockwaveOpos[0], shockwaveOpos[1]);

  grad = loadShader("gradient.glsl");
  grad.set("light", 1f);
  grad.set("deepColor", deepColor[0], deepColor[1], deepColor[2]);
  grad.set("liteColor", liteColor[0], liteColor[1], liteColor[2]);
}

//描画ルーチン
void draw() {
  float fvol = 0;
  int f = int(float(frame) * samplingRate / (frameRate * fftSize));
  if (f < spectra.length) {
    // 震えたりするエフェクト用に一番最初の周波数を取る
    fvol = (spectra[f][SPECTRA_LEFT][0] + spectra[f][SPECTRA_RIGHT][0]) / 256;
  } else {
    // mp3を最後まで読み込んだら終わる
    exit();
  }


  sw.set("size", fvol + 1.5f);
  grad.set("light", pow(fvol + 1f, 3));

  {
    pg.beginDraw();
    // グラデーション
    pg.filter(grad);
    // 線の設定
    pg.strokeWeight(waveWeight);
    pg.stroke(waveColor[0] * 255, waveColor[1] * 255, waveColor[2] * 255);

    int specSize = 0;
    if (f < spectra.length) {
      specSize = spectra[f][SPECTRA_LEFT].length;
    }
    // 波の描画
    for (int d = 0; d < SPECTRA_DIRECTION; d++) {
      for (int i = 0; i < specSize; i += waveInterval) {
        float x = float(width * d) + (0.5 - d) * width * i / specSize;
        float vol = spectra[f][d][i] / 127f * waveVolume;
        float c = vol / (vol + 1);
        float halfHeight = float(height / 2);
        float waveSize = c * height;
        pg.line(x, halfHeight + waveSize, x, halfHeight - waveSize);
      }
    }
    pg.endDraw();
  }
  // 揺れるエフェクト
  pg.filter(sw);
  // ウィンドウに描画
  tint(255, afterimageAlpha * 255);
  image(pg, 0, 0);

  // 中心のロゴ
  translate(logoPos[0] * width, logoPos[1] * height);
  rotate(PI * 2 * fvol / (fvol + 1) * logoAmplitude);
  noTint();
  // NOTE:文字の中央寄せたかったから中心が若干下になってる
  image(pimg, -logoOpos[0] * pimg.width, -logoOpos[1] * pimg.height);

  if (outputFrame) {
    saveFrame("frame/f-######.png");
  }
  frame++;
}

// https://github.com/ddf/Minim/blob/master/examples/Analysis/offlineAnalysis/offlineAnalysis.pde
void analyzeMusic(String filename) {
  Minim minim = new Minim(this);
  AudioSample player = minim.loadSample(filename, 2048);
  float[][] channel = new float[SPECTRA_DIRECTION][];
  channel[SPECTRA_LEFT] = player.getChannel(AudioSample.LEFT);
  channel[SPECTRA_RIGHT] = player.getChannel(AudioSample.RIGHT);
  float[] fftSamples = new float[fftSize];
  FFT fft = new FFT(fftSize, player.sampleRate());
  // NOTE:左右対称なのでtotalChunksは同じはず
  int totalChunks = (channel[SPECTRA_LEFT].length / fftSize) + 1;
  spectra = new float[totalChunks][SPECTRA_DIRECTION][fftSize/2];

  for (int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx)
  {
    int chunkStartIndex = chunkIdx * fftSize;
    for (int d = 0; d < SPECTRA_DIRECTION; d++) {
      int chunkSize = min(channel[d].length - chunkStartIndex, fftSize);
      System.arraycopy(channel[d], chunkStartIndex, fftSamples, 0, chunkSize);
      if (chunkSize < fftSize) {
        java.util.Arrays.fill(fftSamples, chunkSize, fftSamples.length - 1, 0.0);
      }

      fft.forward(fftSamples);

      for (int i = 0; i < fftSize/2; i++) {
        float band = fft.getBand(i);
        spectra[chunkIdx][d][i] = band;
      }
    }
  }

  player.close();
}