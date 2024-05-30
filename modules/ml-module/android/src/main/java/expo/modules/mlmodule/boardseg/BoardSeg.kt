package expo.modules.mlmodule.boardseg

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.github.shiguruikai.combinatoricskt.combinations
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.Mat
import org.opencv.core.MatOfPoint
import org.opencv.core.MatOfPoint2f
import org.opencv.core.Point
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.dnn.Net
import org.opencv.imgproc.Imgproc


class BoardSeg(private val context: Context): Inference, Draw {
    private var results = mutableListOf<Result>()
    private lateinit var net: Net
    private var labels = loadLabel()
    public var board = Mat()

    fun loadModel(){
        net = loadModel(context.assets, context.filesDir.toString())
    }

    fun detectBoard(bitmap: Bitmap){
        val mat = Mat()
        Utils.bitmapToMat(bitmap, mat)

        var input = mat.clone()

        Imgproc.cvtColor(input,input,Imgproc.COLOR_RGBA2GRAY)

        input = prepareInput(input)

        Imgproc.cvtColor(input,input,Imgproc.COLOR_GRAY2RGB)

        results = detect(input, net, labels)

        results.sortedByDescending {
            it.confidence
        }

        results = MutableList(1){results.first()}

        val binaryImage = Mat()

        Imgproc.cvtColor(drawSeg(Mat.zeros(input.size(),input.type()),results,labels), binaryImage, Imgproc.COLOR_RGB2GRAY)

        val corners = getBoardCorners(binaryImage)

        val srcPoints = MatOfPoint2f(
            *corners
        )

        val dstPoints = MatOfPoint2f(  Point(0.0, 0.0),
            Point(640.0, 0.0),
            Point(640.0, 640.0),
            Point(0.0, 640.0))

        val matrix = Imgproc.getPerspectiveTransform(srcPoints,dstPoints)

        val transformedImage = Mat()
        Imgproc.warpPerspective(input, transformedImage, matrix, Size(640.0, 640.0))

        board = transformedImage
    }

    private fun getBoardCorners(binaryImage:Mat):Array<Point>{

        val contours = ArrayList<MatOfPoint>()
        Imgproc.findContours(binaryImage,contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

        var largestContour = -1
        var largestArea = 0.0

        for (i in contours.indices){
            val contourArea = Imgproc.contourArea(contours[i])

            if (contourArea > largestArea){
                largestArea = contourArea
                largestContour = i
            }
        }

        val epsilon = 0.07 * Imgproc.arcLength(MatOfPoint2f(*contours[largestContour].toArray()),true)

        val approxCurve = MatOfPoint2f()

        Imgproc.approxPolyDP(MatOfPoint2f(*contours[largestContour].toArray()),approxCurve,epsilon,true)

        return best4Polygon(approxCurve.toArray())
    }


    private fun best4Polygon(points: Array<Point>):Array<Point> {

        var maxArea = -1.0
        var maxAreaPoints =  Array<Point>(4){Point()}

        points.combinations(4).forEach { it ->
            val sortedCombo = it.sortedBy {
                it.y
            }.toMutableList()

            if(sortedCombo[0].x > sortedCombo[1].x){
                val temp = sortedCombo[0]
                sortedCombo[0] = sortedCombo[1]
                sortedCombo[1] = temp
            }

            if (sortedCombo[2].x < sortedCombo[3].x){
                val temp = sortedCombo[2]
                sortedCombo[2] = sortedCombo[3]
                sortedCombo[3] = temp
            }

            val area = areaQuad(sortedCombo)

            if (maxArea < area) {
                maxArea = area
                maxAreaPoints = sortedCombo.toTypedArray()
            }
        }

        return maxAreaPoints
    }

    private fun prepareInput(mat:Mat):Mat{
        val fillColor = Scalar(128.0)

        val pad = 15

        // Create a new larger image with padding
        val paddedImage = Mat.zeros(
            mat.rows() + (pad * 2),
            mat.cols() + (pad * 2),
            mat.type()
        )

        Imgproc.rectangle(
            paddedImage,
            Point(0.0, 0.0),
            Point(paddedImage.cols().toDouble(), paddedImage.rows().toDouble()),
            fillColor,
            Core.FILLED
        )

        val roi = paddedImage.submat(pad, pad + mat.rows(), pad, pad + mat.cols())
        mat.copyTo(roi)


        return paddedImage
    }

    private fun areaQuad(points:MutableList<Point>):Double{

        val p1 = points[0]
        val p2 = points[1]
        val p3 = points[2]
        val p4 = points[3]

        return  0.5 * (
                (p1.x*p2.y + p2.x*p3.y + p3.x*p4.y + p4.x*p1.y) -
                        (p2.x*p1.y + p3.x*p2.y + p4.x*p3.y + p1.x*p4.y)
                )
    }

}


