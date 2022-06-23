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

static func to_local(obj, vec):
	return (vec - obj.position).rotated(-obj.rotation)

static func sunflower(n, alpha):
	var arr = []
	var b = round(alpha*sqrt(n))
	var phi = (sqrt(5)+1)/2
	for k in range(n):
		var r
		if k>n-b:
			r = 1
		else:
			r = sqrt(k-1/2)/sqrt(n-(b+1)/2); 
		var theta = 2*PI*k/(phi*phi)
		arr.append(Vector2(r*cos(theta), r*sin(theta)))
	return arr
