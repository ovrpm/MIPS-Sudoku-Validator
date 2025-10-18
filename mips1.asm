.data
	num1: .float 2.4
	num2: .float 2.6
.text
	lwc1 $f1, num1
	lwc1 $f2, num2
	add.s $f3, $f1, $f2
	