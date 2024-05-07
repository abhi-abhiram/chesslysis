package expo.modules.mlmodule


import android.util.Log
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record
import org.opencv.android.OpenCVLoader

class MlModule : Module() {
  override fun definition() = ModuleDefinition {

    Name("MlModule")

    AsyncFunction("predict") { image: String, options: Options , promise: Promise ->
      val result = DetectionResult()


      promise.resolve(result)
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
