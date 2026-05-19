import cv2
img = cv2.imread("snp.png")
gry = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
edg = cv2.Canny(gry, 100, 200)
illust = cv2.stylization(img, sigma_s=60, sigma_r=0.07)

cv2.imshow("image1", img)
cv2.imshow("image2", gry)
cv2.imshow("image3", edg)
cv2.imshow("image4", illust)
cv2.waitKey(0)