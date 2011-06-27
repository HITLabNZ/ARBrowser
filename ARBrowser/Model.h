/*
 *  Model.h
 *  ARToolKit-oe
 *
 *  Created by Samuel Williams on 11/11/10.
 *  Copyright 2010 Samuel Williams. All rights reserved.
 *
 */

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
 
#ifndef _ARTOOLKIT_MODEL_H
#define _ARTOOLKIT_MODEL_H

#include "Texture2D.h"
#include "Math/Vector.h"
#include "Math/Matrix.h"
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
#include <map>

namespace ARBrowser {
	typedef std::vector<Vec3> VerticesT;
	
	void generateGrid (VerticesT & points);
	void generateGlobe (VerticesT & points, float radius);

	void renderVertices(const VerticesT & vertices, GLenum mode = GL_LINES);
	
	// Primarily for debugging..
	void renderMarker (float s);
	void renderAxis ();

	struct Color4f {
		float r, g, b, a;
	};
	
	struct ObjMeshVertex {
		Vec3 pos;
		Vec2 texcoord;
		Vec3 normal;
	};

	/* This is a triangle, that we can render */
	struct ObjMeshFace{
		ObjMeshVertex vertices[3];
	};

	/* This contains a list of triangles */
	struct ObjMesh{
		std::string material;
		std::vector<ObjMeshFace> faces;
	};
	
	struct ObjMaterial {
	public:
		ObjMaterial ();
		~ObjMaterial ();
		
		ObjMaterial (const ObjMaterial & other);
		ObjMaterial & operator= (const ObjMaterial & other);
		
		void enable ();
		void disable ();
		
		Color4f ambient;
		
		std::string diffuseMapPath;
		Texture2D * diffuseMapTexture;
	};
	
	struct BoundingBox {
		BoundingBox();
		BoundingBox(Vec3 _min, Vec3 _max);
		
		void add(Vec3 pt);
		
		Vec3 min, max;
		unsigned count;

		// Convert to bounding sphere
		Vec3 center() const;
		float radius() const;
		
		bool intersectsWith(Vec3 origin, Vec3 direction, float & t1, float & t2) const;
	};
	
	struct BoundingSphere {
		BoundingSphere(Vec3 _center, float _radius);
		
		BoundingSphere transform(const Mat44 & transform);
		
		Vec3 center;
		float radius;
		
		bool intersectsWith(Vec3 origin, Vec3 direction, float & t1, float & t2) const;
	};
	
	class Model {
		public:
			typedef std::map<std::string, ObjMaterial> MaterialMapT;
			
		protected:
			std::vector<ObjMesh> m_mesh;
			MaterialMapT m_materials;
			BoundingBox m_boundingBox;
			
			void updateBoundingBox();
			
		public:
			Model (std::string name, std::string directory);
			
			void render ();
			
			const BoundingBox & boundingBox () const { return m_boundingBox; }
	};
	
	struct IntersectionResult {
		unsigned hits;
		Vec3 origin, direction;
		
		std::size_t index;
		float t1, t2;
	};
		
	bool findIntersection(const Mat44 & proj, const Mat44 & view, float viewport[4], const Vec3 & origin, Vec2 screenCoords, const std::vector<BoundingSphere> & spheres, IntersectionResult & result);
}

#endif
