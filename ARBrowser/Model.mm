/*
 *  Model.cpp
 *  ARToolKit-oe
 *
 *  Created by Samuel Williams on 11/11/10.
 *  Copyright 2010 Samuel Williams. All rights reserved.
 *
 */

#include "Model.h"
#include <algorithm>
#include <iostream>

/**
 * The MIT License
 *
 * Copyright (c) 2010 Wouter Lindenhof (http://limegarden.net)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

namespace ARBrowser {

	void generateGrid (VerticesT & points) {		
		const float LOWER = -20;
		const float UPPER = 20;
		const float STEP = 0.5;
		
		for (float x = LOWER; x <= UPPER; x += STEP) {		
			points.push_back(Vec3(x, LOWER, 0));
			points.push_back(Vec3(x, UPPER, 0));
			
			points.push_back(Vec3(LOWER, x, 0));
			points.push_back(Vec3(UPPER, x, 0));
		}
	}
	
	void generateGlobe (VerticesT & points, float radius) {
		const unsigned Y_RES = 100, X_RES = 50;
		Mat44 vr, hr;
		MatrixRotationY(hr, (2 * M_PI) / Y_RES);
		MatrixRotationX(vr, (2 * M_PI) / X_RES);
		
		Vec3 k(0, radius, 0), t;
		
		for (unsigned j = 0; j <= (Y_RES * X_RES); j++) {
			if (j % Y_RES == 0) {
				MatrixVec3Multiply(t, k, vr);
				k = t;
				
				points.push_back(Vec3(k.x, k.y, k.z));
			}
			
			MatrixVec3Multiply(t, k, hr);
			k = t;

			points.push_back(Vec3(k.x, k.y, k.z));
		}
	}
	
	void renderVertices(const VerticesT & vertices, GLenum mode) {
		glVertexPointer(3, GL_FLOAT, 0, &vertices[0]);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		glDrawArrays(mode, 0, vertices.size());
		
		glDisableClientState(GL_VERTEX_ARRAY);
	}

	void renderMarker (float s) {
		float verts[] = {
			s, s,-s,	
			-s, s,-s,	
			-s, s, s,	
			s, s, s,	

			s,-s, s,	
			-s,-s, s,	
			-s,-s,-s,	
			s,-s,-s,	

			s, s, s,	
			-s, s, s,	
			-s,-s, s,	
			s,-s, s,	

			s,-s,-s,	
			-s,-s,-s,	
			-s, s,-s,	
			s, s,-s,	

			s, s,-s,	
			s, s, s,	
			s,-s, s,	
			s,-s,-s,

			-s, s, s,	
			-s, s,-s,	
			-s,-s,-s,	
			-s,-s, s
		};

		glEnableClientState(GL_VERTEX_ARRAY);

		glColor4f(0, 1, 0, 1);
		glVertexPointer(3, GL_FLOAT, 0, verts);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

		glColor4f(1, 0, 1, 1);
		glVertexPointer(3, GL_FLOAT, 0, verts + 12);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

		glColor4f(0, 0, 1, 1);
		glVertexPointer(3, GL_FLOAT, 0, verts + 24);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

		glColor4f(1, 1, 0, 1);
		glVertexPointer(3, GL_FLOAT, 0, verts + 36);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

		glColor4f(1, 0, 0, 1);
		glVertexPointer(3, GL_FLOAT, 0, verts + 48);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

		glColor4f(0, 1, 1, 1);
		glVertexPointer(3, GL_FLOAT, 0, verts + 60);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	}

	void renderAxis ()
	{
		std::vector<Vec3> vertices;
		std::vector<Vec4> colors;
		
		vertices.push_back(Vec3(0, 0, 0));
		colors.push_back(Vec4(1.0, 0.0, 0.0, 1.0));
		 
		vertices.push_back(Vec3(10.0, 0.0, 0.0));
		colors.push_back(Vec4(1.0, 0.0, 0.0, 1.0));
		
		vertices.push_back(Vec3(0, 0, 0));
		colors.push_back(Vec4(0.0, 1.0, 0.0, 1.0));
		
		vertices.push_back(Vec3(0.0, 10.0, 0.0));
		colors.push_back(Vec4(0.0, 1.0, 0.0, 1.0));

		vertices.push_back(Vec3(0, 0, 0));
		colors.push_back(Vec4(0.0, 0.0, 1.0, 1.0));
		
		vertices.push_back(Vec3(0.0, 0.0, 10.0));
		colors.push_back(Vec4(0.0, 0.0, 1.0, 1.0));
		
		glLineWidth(5.0);
		
		glColorPointer(4, GL_FLOAT, 0, &colors[0]);
		glEnableClientState(GL_COLOR_ARRAY);
		
		glVertexPointer(3, GL_FLOAT, 0, &vertices[0]);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		glDrawArrays(GL_LINES, 0, vertices.size());
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		
		glLineWidth(1.0);
	}

	const char * TOKEN_VERTEX_POS = "v";
	const char * TOKEN_VERTEX_NOR = "vn";
	const char * TOKEN_VERTEX_TEX = "vt";
	const char * TOKEN_FACE = "f";
	const char * TOKEN_USE_MATERIAL = "usemtl";

	/* Internal structure */
	struct _ObjMeshFaceIndex{
		std::string material;
		int pos_index[3];
		int tex_index[3];
		int nor_index[3];
	};

	/* Call this function to load a model, only loads triangulated meshes */
	void loadMesh(std::string filename, std::vector<ObjMesh> & mesh) {
		std::vector<Vec3> positions;
		std::vector<Vec2> texcoords;
		std::vector<Vec3> normals;
		std::vector<_ObjMeshFaceIndex> faces;
		std::string currentMaterial = "";
		
		unsigned materialCount = 1;
		
		/**
		 * Load file, parse it
		 * Lines beginning with:
		 * '#'  are comments can be ignored
		 * 'v'  are vertices positions (3 floats that can be positive or negative)
		 * 'vt' are vertices texcoords (2 floats that can be positive or negative)
		 * 'vn' are vertices normals   (3 floats that can be positive or negative)
		 * 'f'  are faces, 3 values that contain 3 values which are separated by / and <space>
		 */
		
		std::ifstream filestream;
		filestream.open(filename.c_str());
		
		// No longer depending on char arrays thanks to: Dale Weiler
		std::string line_stream;
		while(std::getline(filestream, line_stream)) {
			std::stringstream str_stream(line_stream);
			std::string type_str;
			str_stream >> type_str;
			if (type_str == TOKEN_VERTEX_POS) {
				Vec3 pos;
				str_stream >> pos.x >> pos.y >> pos.z;
				positions.push_back(pos);
			} else if (type_str == TOKEN_VERTEX_TEX) {
				Vec2 tex;
				str_stream >> tex.x >> tex.y;
				texcoords.push_back(tex);
			} else if (type_str == TOKEN_VERTEX_NOR) {
				Vec3 nor;
				str_stream >> nor.x >> nor.y >> nor.z;
				normals.push_back(nor);
			} else if (type_str == TOKEN_FACE) {
				_ObjMeshFaceIndex face_index;
				face_index.material = currentMaterial;
				
				char interupt;
				for(int i = 0; i < 3; ++i) {
					str_stream >> face_index.pos_index[i] >> interupt
					>> face_index.tex_index[i]  >> interupt
					>> face_index.nor_index[i];
				}
				faces.push_back(face_index);
			} else if (type_str == TOKEN_USE_MATERIAL) {
				str_stream >> currentMaterial;
				materialCount++;
			}
		}
		// Explicit closing of the file
		filestream.close();
		
		currentMaterial = "";
		mesh.reserve(materialCount);
		ObjMesh * currentMesh = NULL;
		
		for (size_t i = 0; i < faces.size(); ++i) {
			ObjMeshFace face;
			
			if (currentMesh != NULL && currentMaterial != faces[i].material) {
				currentMesh = NULL;
			}
			
			if (currentMesh == NULL) {
				mesh.resize(mesh.size() + 1);
				currentMesh = &mesh.back();
				currentMesh->material = faces[i].material;

				currentMaterial = faces[i].material;				
			}
			
			for(size_t j = 0; j < 3; ++j) {
				face.vertices[j].pos        = positions[faces[i].pos_index[j] - 1];
				face.vertices[j].texcoord   = texcoords[faces[i].tex_index[j] - 1];
				face.vertices[j].normal     = normals[faces[i].nor_index[j] - 1];
			}
			
			currentMesh->faces.push_back(face);
		}
	}
	
	void loadMaterials(std::string filename, Model::MaterialMapT & materials) {
		std::ifstream filestream;
		filestream.open(filename.c_str());
		
		ObjMaterial * material = NULL;
		
		std::string line_stream;
		while(std::getline(filestream, line_stream)) {
			std::stringstream str_stream(line_stream);
			std::string type_str;
			str_stream >> type_str;
			
			if (type_str == "newmtl") {
				std::string name;
				str_stream >> name;
				
				material = &materials[name];
			} else if (type_str == "Ka" && material) {
				str_stream >> material->ambient.r >> material->ambient.g >> material->ambient.b;
				material->ambient.a = 1.0;
			} else if (type_str == "map_Kd") {
				std::string map_path;
				str_stream >> material->diffuseMapPath;
			}
		}
	}
	
	void loadTextures(std::string directory, Model::MaterialMapT & materials) {
		for (Model::MaterialMapT::iterator i = materials.begin(); i != materials.end(); i++) {
			ObjMaterial & material = (*i).second;
			
			std::string fullPath = directory + "/" + material.diffuseMapPath;
			NSString * imagePath = [NSString stringWithCString:fullPath.c_str() encoding:NSUTF8StringEncoding];
			Texture2D * texture = [[Texture2D alloc] initWithImagePath:imagePath];
			material.diffuseMapTexture = texture;
		}
	}
	
	ObjMaterial::ObjMaterial () : diffuseMapTexture(NULL) {
	
	}
	
	ObjMaterial::~ObjMaterial () {
		if (diffuseMapTexture) {
			[diffuseMapTexture release];
		}
	}
	
	ObjMaterial::ObjMaterial (const ObjMaterial & other) {
		(*this) = other;
	}
	
	ObjMaterial & ObjMaterial::operator= (const ObjMaterial & other) {
		this->diffuseMapTexture = [other.diffuseMapTexture retain];	
		this->ambient = other.ambient;
		
		return *this;
	}
		
	void ObjMaterial::enable () {
		if (diffuseMapTexture) {
			glBindTexture(GL_TEXTURE_2D, [diffuseMapTexture name]);
			glColor4f(ambient.r, ambient.g, ambient.b, ambient.a);
		}
	}
	
	void ObjMaterial::disable () {
		glBindTexture(GL_TEXTURE_2D, 0);
		glColor4f(1.0, 1.0, 1.0, 1.0);
	}
	
	Model::Model (std::string name, std::string directory) {
		assert(sizeof(Vec2) == (sizeof(float) * 2));
		assert(sizeof(Vec3) == (sizeof(float) * 3));
		
		loadMesh(directory + "/" + name + ".obj", m_mesh);
		
		if (m_mesh.size() == 0) {
			std::cerr << "Mesh " << name << " in directory " << directory << " had 0 faces!" << std::endl;
		}
		
		loadMaterials(directory + "/" + name + ".mtl", m_materials);
		loadTextures(directory, m_materials);
		updateBoundingBox();
	}
	
	void Model::updateBoundingBox() {
		for (std::size_t i = 0; i < m_mesh.size(); i++) {
			ObjMesh & mesh = m_mesh[i];
			
			for (std::size_t j = 0; j < mesh.faces.size(); j++) {
				m_boundingBox.add(mesh.faces[j].vertices[0].pos);
				m_boundingBox.add(mesh.faces[j].vertices[1].pos);
				m_boundingBox.add(mesh.faces[j].vertices[2].pos);
			}
		}
	}
			
	void Model::render () {		
		if (m_mesh.size() > 0) {
			glEnable(GL_TEXTURE_2D);
			
			for (std::size_t i = 0; i < m_mesh.size(); i++) {
				MaterialMapT::iterator m = m_materials.find(m_mesh[i].material);
				
				if (m != m_materials.end()) {
					m->second.enable();
				}
				
				std::vector<ObjMeshFace> & faces = m_mesh[i].faces;
				
				glEnableClientState(GL_VERTEX_ARRAY);
				glVertexPointer(3, GL_FLOAT, sizeof(ObjMeshVertex), (void*)&(faces[0].vertices[0].pos));
				
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
				glTexCoordPointer(2, GL_FLOAT, sizeof(ObjMeshVertex), (void*)&(faces[0].vertices[0].texcoord));
				
				glEnableClientState(GL_NORMAL_ARRAY);
				glNormalPointer(GL_FLOAT, sizeof(ObjMeshVertex), (void*)&(faces[0].vertices[0].normal));
				
				glDrawArrays(GL_TRIANGLES, 0, faces.size() * 3);
				
				if (m != m_materials.end()) {
					m->second.disable();
				}
			}
			
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisableClientState(GL_NORMAL_ARRAY);
			
			glDisable(GL_TEXTURE_2D);
			
			// Bounding Box Debug
			VerticesT vertices;
			Vec3 a = m_boundingBox.min;
			Vec3 b = m_boundingBox.max;
			
			vertices.push_back(Vec3(a.x, a.y, a.z));
			vertices.push_back(Vec3(b.x, a.y, a.z));

			vertices.push_back(Vec3(a.x, a.y, a.z));
			vertices.push_back(Vec3(a.x, b.y, a.z));
			
			vertices.push_back(Vec3(a.x, a.y, a.z));
			vertices.push_back(Vec3(a.x, a.y, b.z));
			
			vertices.push_back(Vec3(b.x, b.y, b.z));
			vertices.push_back(Vec3(a.x, b.y, b.z));
			
			vertices.push_back(Vec3(b.x, b.y, b.z));
			vertices.push_back(Vec3(b.x, a.y, b.z));
			
			vertices.push_back(Vec3(b.x, b.y, b.z));
			vertices.push_back(Vec3(b.x, b.y, a.z));
			
			glColor4f(0.0, 1.0, 0.0, 1.0);
			renderVertices(vertices, GL_LINES);
		}
	}

	BoundingBox::BoundingBox() : count(0) {
		min = Vec3(0, 0, 0);
		max = Vec3(0, 0, 0);
	}
	
	BoundingBox::BoundingBox(Vec3 _min, Vec3 _max) : min(_min), max(_max), count(0) {
		
	}
/*	
	bool raySlabsIntersection(float start, float dir, float min, float max, float & tfirst, float & tlast)
	{
		if (dir == 0.0)
			return (start < max && start > min);
		
		float tmin = (min - start) / dir;
		float tmax = (max - start) / dir;
		
		if (tmin > tmax) std::swap(tmin, tmax);
		
		if (tmax < tfirst || tmin > tlast)
			return false;
		
		if (tmin > tfirst) tfirst = tmin;
		if (tmax < tlast) tlast = tmax;
		
		return true;
	}
	
	bool BoundingBox::intersectsWith(Vec3 origin, Vec3 direction, float & t1, float & t2) const {
		t1 = 0;
		t2 = 1;

		if (!raySlabsIntersection(origin.x, direction.x, min.x, max.x, t1, t2))
			return false;
		
		if (!raySlabsIntersection(origin.y, direction.y, min.y, max.y, t1, t2))
			return false;
		
		if (!raySlabsIntersection(origin.z, direction.z, min.z, max.z, t1, t2))
			return false;
		
		return true;
	}
*/

	BoundingSphere::BoundingSphere(Vec3 _center, float _radius) : center(_center), radius(_radius) {
		
	}

	bool BoundingSphere::intersectsWith(Vec3 origin, Vec3 direction, float & t1, float & t2) const {
		//Optimized method sphere/ray intersection
		Vec3 dst = origin - center;
		
		float b = dst.dot(direction);
		float c = dst.dot(dst) - (radius * radius);
		
		// If d is negative there are no real roots, so return 
		// false as ray misses sphere
		float d = b * b - c;
		
		if (d == 0.0) {
			t1 = (-b) - sqrtf(d);
			t2 = t1;
			return true; // Edges intersect
		} 
		
		if (d > 0) {
			t1 = (-b) - sqrtf(d);
			t2 = (-b) + sqrtf(d);
			return true; // Line passes through shape
		}
		
		return false;
	}
	
	BoundingSphere BoundingSphere::transform(const Mat44 & transform) {
		Vec3 newCenter, newEdge;
		Vec3 edge = center + (Vec3(1, 0, 0) * radius);
		
		MatrixVec3Multiply(newCenter, center, transform);
		MatrixVec3Multiply(newEdge, edge, transform);
		
		return BoundingSphere(newCenter, (newEdge - newCenter).length());
	}
	
	void BoundingBox::add(Vec3 pt) {
		if (count == 0) {
			min = pt;
			max = pt;
		} else {
			if (pt.x < min.x)
				min.x = pt.x;
			
			if (pt.y < min.y)
				min.y = pt.y;
			
			if (pt.z < min.z)
				min.z = pt.z;
			
			if (pt.x > max.x)
				max.x = pt.x;
			
			if (pt.y > max.y)
				max.y = pt.y;
			
			if (pt.z > max.z)
				max.z = pt.z;
		}
		
		count++;
	}
	
	Vec3 BoundingBox::center() const {
		return (min + max) / 2.0;
	}

	float BoundingBox::radius() const {
		return (max - min).length() / 2.0;
	}
	
	/*
	bool findIntersection(const Mat44 & proj, const Mat44 & view, Vec3 worldOrigin, Vec2 screenCoords, const std::vector<ARToolKit::WorldPoint> & worldPoints, IntersectionResult & result) {
		Mat44 projectionInv, viewInv;
		
		MatrixInverse(projectionInv, proj);
		MatrixInverse(viewInv, view);
		
		// Viewport = (X, Y, Width, Height)
		GLint viewport[4];
		glGetIntegerv(GL_VIEWPORT, viewport);
		
		// Convert screen coordinate to clip coordinates
		screenCoords.x -= viewport[0];
		screenCoords.y -= viewport[1];
		
		screenCoords.x /= viewport[2];
		screenCoords.y /= viewport[3];
		
		screenCoords.x = (screenCoords.x * 2.0) - 1.0;
		screenCoords.y = (screenCoords.y * 2.0) - 1.0;
		
		// Convert to eye coordinates
		Vec3 v1(screenCoords.x, screenCoords.y, -1);
		Vec3 c1;
		
		MatrixVec3Multiply(c1, v1, projectionInv);
		
		// Convert to object coordinates
		Vec3 o1;
		MatrixVec3Multiply(o1, c1, viewInv);
		
		Vec3 origin(viewInv.f[12], viewInv.f[13], viewInv.f[14]);
		Vec3 direction = (o1 - origin).normalized();
		float t1, t2;
		
		bool hit = false;
		result.hits = 0;
		result.index = 0;
		result.origin = origin;
		result.direction = direction;
		
		for (std::size_t i = 0; i < worldPoints.size(); i++) {
			const WorldPoint & pt = worldPoints[i];
			
			if (pt.model) {
				BoundingBox box = pt.model->boundingBox();
				
				BoundingSphere sphere(box.center(), box.radius());
				// Update the sphere center
				sphere = sphere.transform(pt.transformation);
				sphere.center += pt.position;
				
				if (sphere.intersectsWith(origin + worldOrigin, direction, t1, t2)) {
					result.hits++;
					
					if (!hit) {
						hit = true;
						result.index = i;
						result.t1 = t1;
						result.t2 = t2;
					} else {
						if (t1 < result.t1) {
							result.index = i;
							result.t1 = t1;
							result.t2 = t2;
						}
					}
				}
			}
		}
		
		return hit;
	}
	*/
}

