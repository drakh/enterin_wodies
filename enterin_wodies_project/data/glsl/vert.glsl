uniform float tmx;
uniform float chnk;
uniform float rand;
uniform float sprd;
void main() 
{
	vec4 pos = gl_ModelViewMatrix * gl_Vertex;
	float t = tmx + 0.1 * (gl_Vertex.z+rand);
	//pos.x += sprd*1.0 * cos((chnk/1.24) * t) * sin(3.12 * t)*rand;
	//pos.y += sprd*1.0 * sin((chnk+0.01)/2.97 * t) * cos(((chnk+0.01)/0.81)* t)*rand;
	pos.x += (40.0+rand) * sprd * cos(1.24 * t) * sin((3.12+rand) * t);
	pos.y += 40.0 * sprd * sin(2.97 * t) * cos(0.81 * t);
	pos.z += 40.0 * sprd * cos(t) * sin(t * 1.231);
  	gl_Position = gl_ProjectionMatrix * pos;
}