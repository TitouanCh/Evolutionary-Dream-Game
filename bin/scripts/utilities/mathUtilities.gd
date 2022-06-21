extends Reference

class_name AdvMath

static func calc_poly(p, x):
	var sum = 0
	for i in range(len(p)):
		sum += pow(x, i) * p[i]
	return sum

static func make_circle(r, n, coord = Vector2.ZERO):
	var theta = (2 * PI) / n
	var res = []
	
	for i in range(1, n):
		res.append(Vector2(r * cos(theta*i) + coord.x, r * sin(theta*i) + coord.y))
	
	return res
