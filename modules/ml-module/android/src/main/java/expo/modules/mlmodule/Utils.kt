package expo.modules.mlmodule

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.net.Uri
import androidx.core.graphics.createBitmap
import expo.modules.core.utilities.FileUtilities
import expo.modules.kotlin.AppContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runInterruptible
import kotlinx.coroutines.withContext
import org.opencv.android.Utils
import org.opencv.core.Mat
import org.opencv.dnn.Dnn
import org.opencv.dnn.Net
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException


internal suspend fun loadImage(imgUri: String, appContext: AppContext): Bitmap {
    val image = withContext(Dispatchers.IO) {
        appContext.imageLoader!!.loadImageForManipulationFromURL(imgUri).get()
    }
    return image
}

internal  suspend fun getImageUri(img:Bitmap, cacheDirectory:File):String{
    val outputFile = createOutputFile(cacheDirectory, ".jpeg")
    writeImage(img,outputFile)

    return Uri.fromFile(outputFile).toString()
}

internal suspend fun getImageUri(img: Mat, cacheDirectory: File):String{
    val bitmap = createBitmap(img.width(),img.height())

    Utils.matToBitmap(img,bitmap)

    return getImageUri(bitmap,cacheDirectory)
}

private suspend fun writeImage(
    bitmap: Bitmap,
    output: File,
) = runInterruptible {
    try {
        FileOutputStream(output).use { out -> bitmap.compress(Bitmap.CompressFormat.JPEG, 100, out) }
    } catch (cause: FileNotFoundException) {
//        throw
    }
}

internal fun createOutputFile(cacheDir: File, extension: String): File {
    val filePath = FileUtilities.generateOutputPath(cacheDir,"Chesslysis" , extension)
    return try {
        File(filePath).apply { createNewFile() }
    } catch (cause: IOException) {
        throw Exception("Nothing")
    }
}
