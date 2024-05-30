package expo.modules.mlmodule.boardseg

import android.content.res.AssetManager
import org.opencv.dnn.Dnn
import org.opencv.dnn.Net
import java.io.File
import java.io.FileOutputStream

interface Load {

    companion object {
        const val FILE_NAME = "chess-seg-n.onnx"
    }

    fun loadModel(assets: AssetManager, fileDir: String): Net {
        val outputFile = File("$fileDir/$FILE_NAME")
        assets.open(FILE_NAME).use { inputStream ->
            FileOutputStream(outputFile).use { outputStream ->
                val buffer = ByteArray(1024)
                var read: Int
                while (inputStream.read(buffer).also { read = it } != -1) {
                    outputStream.write(buffer, 0, read)
                }
            }
        }
        return Dnn.readNetFromONNX("$fileDir/$FILE_NAME")
    }

    fun loadLabel(): Array<String> {
        return arrayOf("String")
    }
}