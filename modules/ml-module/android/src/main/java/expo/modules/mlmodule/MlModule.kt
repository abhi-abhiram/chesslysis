package expo.modules.mlmodule

import androidx.core.graphics.createBitmap
import expo.modules.kotlin.functions.Coroutine
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record
import expo.modules.mlmodule.boardseg.BoardSeg
import expo.modules.mlmodule.pieces_detector.PiecesDetector
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils

//const val MODEL_PATH = "chess_pieces_float32.tflite"
const val MODEL_PATH = "best_float16.tflite"
const val LABELS_PATH = "labels.txt"

class MlModule : Module() {

  private lateinit var piecesDetector: PiecesDetector
  private lateinit var boardSeg: BoardSeg


  override fun definition() = ModuleDefinition {

    Name("MlModule")

    OnCreate {
      OpenCVLoader.initLocal()
      piecesDetector = PiecesDetector(appContext.reactContext!!.applicationContext, MODEL_PATH, LABELS_PATH)
      piecesDetector.setup()
      boardSeg = BoardSeg(appContext.reactContext!!.applicationContext)
      boardSeg.loadModel()
    }

    AsyncFunction("predict") Coroutine  { image: String, options: Options ->
      val imageBitmap = loadImage(image,appContext)


      boardSeg.detectBoard(imageBitmap)

      val result = DetectionResult()

//      result.boardResult = getImageUri(boardSeg.board,appContext.cacheDirectory)

//      val boardBitmap = createBitmap(boardSeg.board.width(),boardSeg.board.height())

//      Utils.matToBitmap(boardSeg.board,boardBitmap)

//      boardSeg.board.release()

//      val piecesResult = piecesDetector.detect(imageBitmap)

//      piecesResult?.forEach {
//        val x = ((it.x1 + it.x2)/2) * 640
//        val y = ((it.y1 + it.y2)/2) * 640
//
//        val i = (x/ 80).toInt()
//        val j = (y/80).toInt()
//
//        result.positions[j][i] = it.clsName
//      }

      return@Coroutine result
    }
  }
}

class Options : Record {
  @Field
  val verbose: Boolean = false
}

class DetectionResult:Record{
  @Field
  var positions = Array(8) { Array<String?>(8) { null } }

  @Field
  var boardResult:String? = null
}
