extends Reference

class_name AdvMath

static func calc_poly(p, x):
	var sum = 0
	for i in range(len(p)):
		sum += pow(x, i) * p[i]
	return sum
