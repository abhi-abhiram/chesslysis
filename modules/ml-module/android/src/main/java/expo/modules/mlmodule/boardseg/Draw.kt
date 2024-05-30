package expo.modules.mlmodule.boardseg

import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Scalar

interface Draw {
    companion object {
        const val ALPHA = 1.0
    }

    fun drawSeg(mat: Mat, lists: MutableList<Result>, labels: Array<String>): Mat {

        val maskImg = mat.clone()

        if (lists.size == 0) return maskImg

        lists.forEach {
            val box = it.box
            val color = Scalar(255.0, 255.0, 255.0)

            val cropMask = it.maskMat
            val cropMaskImg = Mat(maskImg, box)
            val cropMaskRGB = Mat(cropMask.size(), CvType.CV_8UC3)
            val list = List(3) { cropMask.clone() }
            Core.merge(list, cropMaskRGB)

            val temp1 = Mat.zeros(cropMaskRGB.size(), cropMaskRGB.type())
            Core.add(temp1, Scalar(1.0, 1.0, 1.0), temp1)
            Core.subtract(temp1, cropMaskRGB, temp1)
            Core.multiply(cropMaskImg, temp1, cropMaskImg)

            val temp2 = Mat()
            Core.multiply(cropMaskRGB, color, temp2)
            Core.add(cropMaskImg, temp2, cropMaskImg)

            cropMaskImg.release()
            temp1.release()
            temp2.release()
            cropMaskRGB.release()
            list.forEach { mat -> mat.release() }
        }

        return maskImg
    }
}