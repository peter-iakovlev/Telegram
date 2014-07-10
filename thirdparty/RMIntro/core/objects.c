//
//  objects.c
//  IntroOpenGL
//
//  Created by Ilya Rimchikov on 29/03/14.
//  Copyright (c) 2014 IntroOpenGL. All rights reserved.
//


#include "objects.h"
#include "buffer.h"
#include "platform_gl.h"
#include "program.h"
#include "shader.h"
#include "linmath.h"
#include "matrix.h"
#include "math_helper.h"

#include "platform_log.h"
#include <math.h>
#include "animations.h"


static TextureProgram texture_program;
static TextureProgram texture_program_one;
static TextureProgram texture_program_red;
static TextureProgram texture_program_blue;
static TextureProgram texture_program_light_red;
static TextureProgram texture_program_light_blue;

static TextureProgram *texture_program_temp;

static ColorProgram color_program;
static GradientProgram gradient_program;

static float y_offset;



void set_y_offset_objects(float a)
{
    y_offset=a;
    
}

void setup_shaders()
{
    
    
    char *vshader =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "void main(){"
    "   gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    char *fshader =
    "precision lowp float;"
    "uniform vec4 u_Color;"
    "uniform float u_Alpha;"
    "void main() {"
    "   gl_FragColor = u_Color;"
    //"   gl_FragColor = vec4(0,1,0,1);"
    "   gl_FragColor.w*=u_Alpha;"
    "}";
    
    color_program = get_color_program(build_program(vshader, strlen(vshader), fshader, strlen(fshader)));
    
    
    char *vertex_gradient_shader =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "attribute vec4 a_Color;"
    "varying vec4 v_DestinationColor;"
    "void main(){"
    "   v_DestinationColor = a_Color;"
    "   gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    char *fragment_gradient_shader =
    "precision lowp float;"
    "uniform float u_Alpha;"
    "varying vec4 v_DestinationColor;"
    "void main() {"
    "   gl_FragColor = v_DestinationColor;"
    "   gl_FragColor.w*=u_Alpha;"
    //"   gl_FragColor = vec4(0,1,0,1);"
    "}";
    
    gradient_program = get_gradient_program(build_program(vertex_gradient_shader, strlen(vertex_gradient_shader), fragment_gradient_shader, strlen(fragment_gradient_shader)));
    
    
    
    char* vshader_texture  =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "attribute vec2 a_TextureCoordinates;"
    "varying vec2 v_TextureCoordinates;"
    "void main(){"
    "    v_TextureCoordinates = a_TextureCoordinates;"
    "    gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    char* fshader_texture  =
    "precision lowp float;"
    "uniform sampler2D u_TextureUnit;"
    "varying vec2 v_TextureCoordinates;"
    "uniform float u_Alpha;"
    "void main(){"
    "    gl_FragColor = texture2D(u_TextureUnit, v_TextureCoordinates);"
    "    gl_FragColor.w *= u_Alpha;"
    "}";
    
    texture_program = get_texture_program(build_program(vshader_texture, strlen(vshader_texture), fshader_texture, strlen(fshader_texture)));
    
    
    
    
    
    
    char* vshader_texture_blue  =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "attribute vec2 a_TextureCoordinates;"
    "varying vec2 v_TextureCoordinates;"
    "void main(){"
    "    v_TextureCoordinates = a_TextureCoordinates;"
    "    gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    char* fshader_texture_blue  =
    "precision lowp float;"
    "uniform sampler2D u_TextureUnit;"
    "varying vec2 v_TextureCoordinates;"
    "uniform float u_Alpha;"
    "void main(){"
    "    gl_FragColor = texture2D(u_TextureUnit, v_TextureCoordinates);"
    "   float p = u_Alpha*gl_FragColor.w*0.4;"
    "   gl_FragColor = vec4(0,0.353,0.761,p);"
    "}";
    
    texture_program_blue = get_texture_program(build_program(vshader_texture_blue, strlen(vshader_texture_blue), fshader_texture_blue, strlen(fshader_texture_blue)));
    
    
    
    
    
    char* vshader_texture_red  =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "attribute vec2 a_TextureCoordinates;"
    "varying vec2 v_TextureCoordinates;"
    "void main(){"
    "    v_TextureCoordinates = a_TextureCoordinates;"
    "    gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    char* fshader_texture_red  =
    "precision lowp float;"
    "uniform sampler2D u_TextureUnit;"
    "varying vec2 v_TextureCoordinates;"
    "uniform float u_Alpha;"
    "void main(){"
    "   gl_FragColor = texture2D(u_TextureUnit, v_TextureCoordinates);"
    "   float p = gl_FragColor.w*0.45*u_Alpha;"
    "   gl_FragColor = vec4(0.722,0.035,0,p);"
    "}";
    
    texture_program_red = get_texture_program(build_program(vshader_texture_red, strlen(vshader_texture_red), fshader_texture_red, strlen(fshader_texture_red)));
    
    
    
    
    vshader  =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "attribute vec2 a_TextureCoordinates;"
    "varying vec2 v_TextureCoordinates;"
    "void main(){"
    "    v_TextureCoordinates = a_TextureCoordinates;"
    "    gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    fshader  =
    "precision lowp float;"
    "uniform sampler2D u_TextureUnit;"
    "varying vec2 v_TextureCoordinates;"
    "uniform float u_Alpha;"
    "void main(){"
    "    gl_FragColor = texture2D(u_TextureUnit, v_TextureCoordinates);"
    "    float p = u_Alpha*gl_FragColor.w;"
    "    gl_FragColor = vec4(237./255., 64./255., 27./255., p);"
    "}";
    
    texture_program_light_red = get_texture_program(build_program(vshader, strlen(vshader), fshader, strlen(fshader)));
    
    
    
    vshader  =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "attribute vec2 a_TextureCoordinates;"
    "varying vec2 v_TextureCoordinates;"
    "void main(){"
    "    v_TextureCoordinates = a_TextureCoordinates;"
    "    gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    fshader  =
    "precision lowp float;"
    "uniform sampler2D u_TextureUnit;"
    "varying vec2 v_TextureCoordinates;"
    "uniform float u_Alpha;"
    "void main(){"
    "    gl_FragColor = texture2D(u_TextureUnit, v_TextureCoordinates);"
    "   float p = u_Alpha*gl_FragColor.w;"
    "    gl_FragColor = vec4(100./255.,182./255.,248./255.,p);"
    "}";
    
    texture_program_light_blue = get_texture_program(build_program(vshader, strlen(vshader), fshader, strlen(fshader)));
    
    
    
    
    
    
    
    
    vshader  =
    "uniform mat4 u_MvpMatrix;"
    "attribute vec4 a_Position;"
    "attribute vec2 a_TextureCoordinates;"
    "varying vec2 v_TextureCoordinates;"
    "void main(){"
    "    v_TextureCoordinates = a_TextureCoordinates;"
    "    gl_Position = u_MvpMatrix * a_Position;"
    "}";
    
    fshader  =
    "precision lowp float;"
    "uniform sampler2D u_TextureUnit;"
    "varying vec2 v_TextureCoordinates;"
    "uniform float u_Alpha;"
    "void main(){"
    "    gl_FragColor = texture2D(u_TextureUnit, v_TextureCoordinates);"
    "    gl_FragColor *= u_Alpha;"
    "}";
    
    texture_program_one = get_texture_program(build_program(vshader, strlen(vshader), fshader, strlen(fshader)));
}


CPoint CPointMake(float x, float y)
{
    CPoint p = {x, y};
    return p;
}

CSize CSizeMake(float width, float height)
{
    CSize s = {width, height};
    return s;
}


float D2R(float a)
{
    return a*M_PI/180.0;
}

float R2D(float a)
{
    return a*180.0/M_PI;
}


xyz xyzMake(float x, float y, float z) {
    xyz result;
    result.x = x;
    result.y = y;
    result.z = z;
    return result;
}



LayerParams default_layer_params()
{
    LayerParams params;
    params.anchor.x=params.anchor.y=params.anchor.z=0;
    params.position.x=params.position.y=params.position.z=0;
    params.rotation=0;
    params.scale.x=params.scale.y=params.scale.z=1.;
    
    return params;
}


Params default_params()
{
    Params params;
    params.anchor.x=params.anchor.y=params.anchor.z=0;
    params.position.x=params.position.y=params.position.z=0;
    params.rotation=0;
    params.scale.x=params.scale.y=params.scale.z=1.;
    params.alpha=1.;
    
    params.var_params.side_length=0;
    params.var_params.start_angle=0;
    params.var_params.end_angle=0;
    params.var_params.angle=0;
    params.var_params.size=CSizeMake(0, 0);
    params.var_params.radius=0;
    params.var_params.width=0;
    
    
    params.const_params.is_star=0;
    
    LayerParams p = default_layer_params();
    
    params.layer_params=&p;
    
    return params;
}






void mat4x4_translate_independed(mat4x4 m, float x, float y, float z)
{
    mat4x4 tr;
    mat4x4_identity(tr);
    
    mat4x4_translate_in_place(tr, x, y, z);
    
    
    //mat4x4 model_matrix2_tr;
    //mat4x4_mul(model_matrix2_tr, tr, m);
    
    
    mat4x4 m_dup;
    mat4x4_dup(m_dup, m);
    mat4x4_mul(m, tr, m_dup );
}


//static int tt;




static inline void mvp_matrix(mat4x4 model_view_projection_matrix, Params params, mat4x4 view_projection_matrix)
{
    //y_offset = -50;
    
    //tt++;
    
    mat4x4 model_matrix;
    mat4x4_identity(model_matrix);
    
    mat4x4 id;
    mat4x4_identity(id);
    
    
    mat4x4_translate(model_matrix, -params.anchor.x, -params.anchor.y, params.anchor.z);
    
    mat4x4 scaled;
    mat4x4_identity(scaled);
    mat4x4_scale_aniso(scaled, scaled, params.scale.x, -params.scale.y, params.scale.z);
    
    
    mat4x4 tmp;
    mat4x4_dup(tmp, model_matrix);
    
    mat4x4_mul(model_matrix, scaled, tmp);
    
    
    
    
    
    mat4x4 rotate;
    mat4x4_dup(rotate, id);
    mat4x4_rotate_Z2(rotate, id, deg_to_radf(-params.rotation));
    
    
    mat4x4_dup(tmp, model_matrix);
    
    mat4x4_mul(model_matrix, rotate, tmp);
    
    mat4x4_translate_independed(model_matrix, params.position.x, -params.position.y, params.position.z);
    
    
    
    mat4x4 model_matrix3;
    mat4x4_identity(model_matrix3);
    
    
    
    
    
    mat4x4 mm;
    
    mat4x4_mul(mm, model_matrix3, view_projection_matrix);
    
    mat4x4_translate_independed(mm, 0, -y_offset/view_projection_matrix[3][3], 0);
    
    mat4x4_mul(model_view_projection_matrix, mm, model_matrix);
    
}









static inline int size_of_rounded_rectangle_in_vertices(int round_count) {
    return 4*(2+round_count)+2;
}

static inline void gen_rounded_rectangle(CPoint* out, CSize size, float radius, int round_count)
{
    
    //printf("gen_rounded_rectangle> %d \n", round_count);
    int offset=0;
    
    out[offset++] = CPointMake(0, 0);
    
    float k = M_PI/2/(round_count+1);
    
    int i=0;
    int n=0;
    
    
    for (i=(round_count+2)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*radius, size.height/2-radius + sin(i*k)*radius);
    }
    n++;
    
    for (i=(round_count+1)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(-size.width/2+radius + cos(i*k)*radius, size.height/2-radius + sin(i*k)*radius);
    }
    n++;
    
    for (i=(round_count+1)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(-size.width/2+radius + cos(i*k)*radius, -size.height/2+radius + sin(i*k)*radius);
    }
    n++;
    
    for (i=(round_count+1)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*radius, -size.height/2+radius + sin(i*k)*radius);
    }
    n++;
    
    out[offset++] = CPointMake(size.width/2, size.height/2-radius);
    
}


Shape create_rounded_rectangle(CSize size, float radius, int round_count, vec4 color)
{
    int real_vertex_count = size_of_rounded_rectangle_in_vertices(round_count);
    
    CPoint *data = malloc(sizeof(CPoint)*real_vertex_count*2);
    
    Params params = default_params();
    params.const_params.round_count=round_count;
    
    params.var_params.size=size;
    params.var_params.radius=radius;
    
    gen_rounded_rectangle(data, params.var_params.size, params.var_params.radius, params.const_params.round_count);
    
    params.const_params.triangle_mode = GL_TRIANGLE_FAN;
    return (Shape) {{color[0], color[1], color[2], color[3]},
        data,
        create_vbo(sizeof(data), data, GL_DYNAMIC_DRAW),
        real_vertex_count,
        params};
}

void change_rounded_rectangle(Shape* shape, CSize size, float radius)
{
    
    if ((*shape).params.var_params.size.width != size.width || (*shape).params.var_params.size.height != size.height || (*shape).params.var_params.radius != radius )
    {
        //DEBUG_LOG_WRITE_D("fps","change_rounded_rectangle");
        
        (*shape).params.var_params.size.width = size.width;
        (*shape).params.var_params.size.height = size.height;
        (*shape).params.var_params.radius = radius;
        
        gen_rounded_rectangle((*shape).data, (*shape).params.var_params.size, (*shape).params.var_params.radius, (*shape).params.const_params.round_count);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        glBufferSubData(GL_ARRAY_BUFFER, 0, shape->num_points*sizeof(CPoint), shape->data);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    
}



void mat4x4_log(mat4x4 M)
{
    printf("\n\n");
    
    int i, j;
    for(i=0; i<4; ++i)
    {
        for(j=0; j<4; ++j)
        {
            printf("%6.2f ", M[i][j]);
        }
        printf("\n");
    }
    
    printf("\n\n");
}

void vec4_log(vec4 M)
{
    printf("\n\n");
    
    int i;
    for(i=0; i<4; ++i)
    {
        
        printf("%6.2f ", M[i]);
        
    }
    
    printf("\n\n");
}

void draw_shape(const Shape* shape, mat4x4 view_projection_matrix)
{
    if (shape->params.alpha>0 && (fabs(shape->params.scale.x)>0 && fabs(shape->params.scale.y)>0 && fabs(shape->params.scale.z)>0))
    {
        
        mat4x4 model_view_projection_matrix;
        mvp_matrix(model_view_projection_matrix, shape->params, view_projection_matrix);
        
        
        if (shape->params.const_params.is_star==1) {
            vec4 pos;
            vec4 vertex = {0,0,0,1};
            mat4x4_mul_vec4(pos, model_view_projection_matrix, vertex);
            
            vec4 p_NDC = {pos[0]/pos[3], pos[1]/pos[3], pos[2]/pos[3], pos[3]/pos[3]};
            
            vec4 p_window={p_NDC[0]*200, -p_NDC[1]*200, 0, 0};
            
            if (fabs(p_window[0])>155 || p_window[1]>140 || p_window[1]<-130) {
                return;
            }
            //inc_stars_rendered();
        }
        
        
        glUseProgram(color_program.program);
        
        
        glUniformMatrix4fv(color_program.u_mvp_matrix_location, 1, GL_FALSE, (GLfloat*)model_view_projection_matrix);
        if (shape->params.rotation==5.) {
            glUniform4fv(color_program.u_color_location, 1, shape->color);
        }
        else if (shape->params.rotation==10.)
        {
            vec4 col ={0,1,0,1};
            glUniform4fv(color_program.u_color_location, 1, col);
            //glUniform4fv(color_program.u_color_location, 1, shape->color);
        }
        else
        {
            glUniform4fv(color_program.u_color_location, 1, shape->color);
        }
        
        glUniform1f(color_program.u_alpha_loaction, shape->params.alpha);
        
        glVertexAttribPointer(color_program.a_position_location, 2, GL_FLOAT, GL_FALSE, sizeof(CPoint), &shape->data[0].x);
        glEnableVertexAttribArray(color_program.a_position_location);
        glDrawArrays(shape->params.const_params.triangle_mode, 0, shape->num_points);
        
        
    }
    
}

void draw_textured_shape(const TexturedShape* shape, mat4x4 view_projection_matrix, texture_program_type program_type)
{
    if (shape->params.alpha>0 && (fabs(shape->params.scale.x)>0 && fabs(shape->params.scale.y)>0 && fabs(shape->params.scale.z)>0))
    {
        
        mat4x4 model_view_projection_matrix;
        mvp_matrix(model_view_projection_matrix, shape->params, view_projection_matrix);
        
        if (program_type==RED) {
            texture_program_temp=&texture_program_red;
        }
        else if (program_type==BLUE)
        {
            texture_program_temp=&texture_program_blue;
        }
        else if (program_type==LIGHT_RED)
        {
            texture_program_temp=&texture_program_light_red;
        }
        else if (program_type==LIGHT_BLUE)
        {
            texture_program_temp=&texture_program_light_blue;
        }
        else if (program_type==NORMAL_ONE)
        {
            texture_program_temp=&texture_program_one;
        }
        else
        {
            texture_program_temp=&texture_program;
        }
        
        
        glUseProgram(texture_program_temp->program);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, shape->texture);
        glUniformMatrix4fv(texture_program_temp->u_mvp_matrix_location, 1, GL_FALSE, (GLfloat*)model_view_projection_matrix);
        glUniform1i(texture_program_temp->u_texture_unit_location, 0);
        glUniform1f(texture_program_temp->u_alpha_loaction, shape->params.alpha);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        // glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
        glVertexAttribPointer(texture_program_temp->a_position_location, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GL_FLOAT), BUFFER_OFFSET(0));
        glVertexAttribPointer(texture_program_temp->a_texture_coordinates_location, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GL_FLOAT), BUFFER_OFFSET(2 * sizeof(GL_FLOAT)));
        glEnableVertexAttribArray(texture_program_temp->a_position_location);
        glEnableVertexAttribArray(texture_program_temp->a_texture_coordinates_location);
        glDrawArrays(shape->params.const_params.triangle_mode, 0, shape->num_points);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
    }
}





static inline int size_of_segmented_square_in_vertices() {
    return 7;
}

static inline CPoint square_point(float angle, float radius)
{
    CPoint p;
    
    if (angle<=M_PI/2*.5 || angle>M_PI/2*3.5)
    {
        p = CPointMake(radius, radius * sin(angle)/cos(angle));
    }
    else if (angle<=M_PI/2*1.5)
    {
        p = CPointMake(radius * cos(angle)/sin(angle), radius);
    }
    else if (angle<=M_PI/2*2.5)
    {
        p = CPointMake(-radius, -radius * sin(angle)/cos(angle));
    }
    else if (angle<=M_PI/2*3.5)
    {
        p = CPointMake(-radius * cos(angle)/sin(angle), -radius);
    }
    
    return p;
}





static inline CPoint square_texture_point(CPoint p, float side_length)
{
    return CPointMake((-p.x/side_length*.5 +.5), -p.y/side_length*.5 +.5);
}


static inline void gen_segmented_square(CPoint* out, float side_length, float start_angle, float end_angle)
{
    
    //CGPathRef p = [self circlePathForPoint:CGPointMake(self.bounds.size.width/2 + sin(self.endAngle)*6, self.bounds.size.height/2 - cos(self.endAngle)*6) radius:self.bounds.size.height/2 startAngle:self.startAngle endAngle:self.endAngle];
    
    CPoint p;
    
    float radius = side_length;
    
    int offset=0;
    
    float k=1;
    
    float da=D2R(-2.6*2)*k;
    
    //0
    p = CPointMake(sin(start_angle+end_angle)*6*k, - cos(start_angle+end_angle)*6*k);
    //p = CPointMake(0, 0);
    
    out[offset++] = p;
    out[offset++] = square_texture_point(p, side_length);
    
    
    //1
    p = square_point(start_angle+da, radius);
    //p.y=p.y;
    //p.y=side_length;
    out[offset++] = p;
    out[offset++] = square_texture_point(p, side_length);
    
    
    int q=0;
    
    
    int i;
    for (i=start_angle; i<floor(R2D(start_angle+end_angle)); i++) {
        if ((i+45)%90==0) {
            p = square_point(D2R(i), radius);
            out[offset++] = p;
            out[offset++] = square_texture_point(p, side_length);
            q++;
        }
    }
    
    
    
    //float da=D2R(-2.6)*k;
    
    
    p = square_point(start_angle + end_angle+da, radius);
    //p.x = p.x + sin(end_angle)*6*k;
    //p.y = p.y - cos(end_angle)*6*k;
    out[offset++] = p;
    out[offset++] = square_texture_point(p, side_length);
    
    
    for (i=0; i<4-q; i++) {
        p = square_point(start_angle +end_angle+da, radius);
        //p.x = p.x + sin(end_angle)*6*k;
        //p.y = p.y - cos(end_angle)*6*k;
        out[offset++] = p;
        out[offset++] = square_texture_point(p, side_length);
    }
    
}



TexturedShape create_segmented_square(float side_length, float start_angle, float end_angle, GLuint texture)
{
    int real_vertex_count = size_of_segmented_square_in_vertices();
    
    CPoint data[real_vertex_count * 2 * 2];
    
    gen_segmented_square(data, side_length, start_angle, end_angle);
    
    
    Params params = default_params();
    
    
    params.const_params.triangle_mode = GL_TRIANGLE_FAN;
    return (TexturedShape) {texture,
        data,
        create_vbo(sizeof(data), data, GL_DYNAMIC_DRAW),
        real_vertex_count,
        params};
}

void change_segmented_square(TexturedShape* shape, float side_length, float start_angle, float end_angle)
{
    
    if ((*shape).params.var_params.side_length != side_length
        || (*shape).params.var_params.start_angle != start_angle
        || (*shape).params.var_params.end_angle != end_angle )
    {
        
        //DEBUG_LOG_WRITE_D("fps","change_segmented_square");
        
        (*shape).params.var_params.side_length = side_length;
        (*shape).params.var_params.start_angle = start_angle;
        (*shape).params.var_params.end_angle = end_angle;
        
        
        
        gen_segmented_square((*shape).data, side_length, start_angle, end_angle);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        glBufferSubData(GL_ARRAY_BUFFER, 0, shape->num_points*sizeof(CPoint)*2, shape->data);
        //glBufferData(GL_ARRAY_BUFFER, textured_shape->num_points*sizeof(CPoint)*2, textured_shape->data, GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    
}



static inline void gen_rectangle(CPoint* out, CSize size)
{
    int offset=0;
    
    out[offset++] = CPointMake(-size.width/2, -size.height/2);
    out[offset++] = CPointMake(size.width/2, -size.height/2);
    out[offset++] = CPointMake(-size.width/2, size.height/2);
    out[offset++] = CPointMake(size.width/2, size.height/2);
    
}


Shape create_rectangle(CSize size, vec4 color)
{
    int real_vertex_count = 4;
    
    CPoint *data = malloc(sizeof(CPoint)*real_vertex_count);
    //CPoint data[real_vertex_count];
    
    gen_rectangle(data, size);
    
    Params params=default_params();
    params.const_params.triangle_mode=GL_TRIANGLE_STRIP;
    
    return (Shape) {{color[0], color[1], color[2], color[3]},
        data,
        create_vbo(sizeof(data), data, GL_DYNAMIC_DRAW),
        real_vertex_count,
        params};
}



static inline CPoint rectangle_texture_point(CPoint p, CSize size)
{
    return CPointMake(1-(-p.x/size.width+.5), p.y/size.height+.5);
}

static inline void gen_textured_rectangle(CPoint* out, CSize size)
{
    int offset=0;
    
    out[offset++] = CPointMake(-size.width/2, -size.height/2);
    out[offset++] = rectangle_texture_point(CPointMake(-size.width/2, -size.height/2), size);
    
    out[offset++] = CPointMake(size.width/2, -size.height/2);
    out[offset++] = rectangle_texture_point(CPointMake(size.width/2, -size.height/2), size);
    
    out[offset++] = CPointMake(-size.width/2, size.height/2);
    out[offset++] = rectangle_texture_point(CPointMake(-size.width/2, size.height/2), size);
    
    out[offset++] = CPointMake(size.width/2, size.height/2);
    out[offset++] = rectangle_texture_point(CPointMake(size.width/2, size.height/2), size);
    
}


void change_textured_rectangle(TexturedShape* shape, CSize size)
{
    //DEBUG_LOG_WRITE_D("fps","change_textured_rectangle");
    
    gen_textured_rectangle((*shape).data, size);
    
    glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, shape->num_points*sizeof(CPoint)*2, shape->data);
    //glBufferData(GL_ARRAY_BUFFER, shape->num_points*sizeof(CPoint)*2, shape->data, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
}

TexturedShape create_textured_rectangle(CSize size, GLuint texture)
{
    int real_vertex_count = 4;
    
    CPoint data[real_vertex_count*2*2];
    
    gen_textured_rectangle(data, size);
    
    Params params=default_params();
    
    
    params.const_params.triangle_mode = GL_TRIANGLE_STRIP;
    return (TexturedShape) {texture,
        &data,
        create_vbo(sizeof(data), data, GL_STATIC_DRAW),
        real_vertex_count,
        params};
}



GradientQuad create_gradient_quad(vec4 top_color, vec4 bottom_color)
{
    
    float data[] = {
        -160, -160, top_color[0], top_color[1], top_color[2], top_color[3],
        160, -160, top_color[0], top_color[1], top_color[2], top_color[3],
        -160, 160, bottom_color[0], bottom_color[1], bottom_color[2], bottom_color[3],
        160, 160, bottom_color[0], bottom_color[1], bottom_color[2], bottom_color[3],
    };
    
    int real_vertex_count = sizeof(data)/(sizeof(float)*6);
    
    Params params=default_params();
    
    params.const_params.triangle_mode=GL_TRIANGLE_STRIP;
    return (GradientQuad) {
        create_vbo(sizeof(data), data, GL_STATIC_DRAW),
        real_vertex_count,
        params};
}


void draw_gradient_quad(const GradientQuad* shape, mat4x4 view_projection_matrix)
{
    if (shape->params.alpha>0 && (fabs(shape->params.scale.x)>0 && fabs(shape->params.scale.y)>0 && fabs(shape->params.scale.z)>0))
    {
        
        mat4x4 model_view_projection_matrix;
        mvp_matrix(model_view_projection_matrix, shape->params, view_projection_matrix);
        
        glUseProgram(gradient_program.program);
        
        glUniformMatrix4fv(gradient_program.u_mvp_matrix_location, 1, GL_FALSE, (GLfloat*)model_view_projection_matrix);
        glUniform1f(gradient_program.u_alpha_loaction, shape->params.alpha);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        // glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
        glVertexAttribPointer(gradient_program.a_position_location, 2, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), BUFFER_OFFSET(0));
        glVertexAttribPointer(gradient_program.a_color_location, 4, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), BUFFER_OFFSET(2 * sizeof(GL_FLOAT)));
        glEnableVertexAttribArray(gradient_program.a_position_location);
        glEnableVertexAttribArray(gradient_program.a_color_location);
        glDrawArrays(shape->params.const_params.triangle_mode, 0, shape->num_points);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
    }
}




static inline void gen_ribbon(CPoint* out, float length)
{
    int offset=0;
    
    out[offset++] = CPointMake(-MAXf(length-5.5, 0), -5.5);
    out[offset++] = CPointMake(0, -5.5);
    out[offset++] = CPointMake(-MAXf(length, 0), 5.5);
    out[offset++] = CPointMake(0, 5.5);
    
}


void change_ribbon(Shape* shape, float length)
{
    if ((*shape).params.var_params.side_length != length)
    {
        
        //DEBUG_LOG_WRITE_D("fps","change_segmented_square");
        
        (*shape).params.var_params.side_length = length;
        
        gen_ribbon((*shape).data, length);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        glBufferSubData(GL_ARRAY_BUFFER, 0, shape->num_points*sizeof(CPoint), shape->data);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
}

Shape create_ribbon(float length, vec4 color)
{
    
    int real_vertex_count = 4;
    
    CPoint *data = malloc(sizeof(CPoint)*real_vertex_count);
    
    gen_ribbon(data, length);
    
    
    Params params=default_params();
    params.var_params.side_length=length;
    
    params.const_params.triangle_mode = GL_TRIANGLE_STRIP;
    return (Shape) {{color[0], color[1], color[2], color[3]},
        data,
        create_vbo(sizeof(data), data, GL_DYNAMIC_DRAW),
        real_vertex_count,
        params};
}






static inline int size_of_segmented_circle_in_vertices(int num_points) {
    return 1 + (num_points + 1);
}

static inline void gen_segmented_circle(CPoint* out, float radius, float start_angle, float angle, int vertex_count)
{
    int offset=0;
    
    out[offset++] = CPointMake(0, 0);
    
    int i;
    for (i = 0; i <= vertex_count; i++) {
        out[offset++] = CPointMake(radius*cos(start_angle+(i/(float)vertex_count)*angle), radius*sin(start_angle+(i/(float)vertex_count)*angle));
        //out[offset++] = CPointMake(10,10);
        
        int o=offset-1;
        //printf("seg>%f %f\n", out[o].x, out[o].y);
    }
    
}




Shape create_segmented_circle(float radius, int vertex_count, float start_angle, float angle, vec4 color)
{
    int real_vertex_count = size_of_segmented_circle_in_vertices(vertex_count);
    
    //CPoint data[real_vertex_count];
    CPoint *data = malloc(sizeof(CPoint)*real_vertex_count);
    
    gen_segmented_circle(data, radius, start_angle, angle, vertex_count);
    
    Params params=default_params();
    params.const_params.triangle_mode=GL_TRIANGLE_FAN;
    
    params.const_params.round_count=vertex_count;
    
    return (Shape) {{color[0], color[1], color[2], color[3]},
        data,
        create_vbo(sizeof(data), data, GL_DYNAMIC_DRAW),
        real_vertex_count,
        params};
}

void change_segmented_circle(Shape* shape, float radius, float start_angle, float angle)
{
    if ((*shape).params.var_params.radius != radius
        || (*shape).params.var_params.start_angle != start_angle
        || (*shape).params.var_params.angle != angle )
    {
        
        //DEBUG_LOG_WRITE_D("fps","change_segmented_square");
        
        (*shape).params.var_params.radius = radius;
        (*shape).params.var_params.start_angle = start_angle;
        (*shape).params.var_params.angle = angle;
        
        
        
        gen_segmented_circle((*shape).data, radius, start_angle, angle, (*shape).params.const_params.round_count);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        glBufferSubData(GL_ARRAY_BUFFER, 0, shape->num_points*sizeof(CPoint), shape->data);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
}






static inline int size_of_circle_in_vertices(int num_points) {
    return 1 + (num_points + 1);
}

static inline void gen_circle(CPoint* out, float radius, int vertex_count)
{
    int offset=0;
    
    out[offset++] = CPointMake(0, 0);
    
    int i;
    for (i = 0; i <= vertex_count; i++) {
        out[offset++] = CPointMake(radius*cos(2*M_PI*(i/(float)vertex_count)), radius*sin(2*M_PI*(i/(float)vertex_count)) );
    }
    
}




Shape create_circle(float radius, int vertex_count, vec4 color)
{
    int real_vertex_count = size_of_segmented_circle_in_vertices(vertex_count);
    
    //CPoint data[real_vertex_count];
    CPoint *data = malloc(sizeof(CPoint)*real_vertex_count);
    
    gen_circle(data, radius, vertex_count);
    
    Params params=default_params();
    params.const_params.triangle_mode=GL_TRIANGLE_FAN;
    
    params.const_params.round_count=vertex_count;
    
    return (Shape) {{color[0], color[1], color[2], color[3]},
        data,
        create_vbo(sizeof(data), data, GL_STATIC_DRAW),
        real_vertex_count,
        params};
}

void change_circle(Shape* shape, float radius)
{
    if ((*shape).params.var_params.radius != radius)
    {
        
        //DEBUG_LOG_WRITE_D("fps","change_segmented_square");
        
        (*shape).params.var_params.radius = radius;
        
        gen_circle((*shape).data, radius, (*shape).params.const_params.round_count);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        glBufferSubData(GL_ARRAY_BUFFER, 0, shape->num_points*sizeof(CPoint), shape->data);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
}



int size_of_infinity_in_vertices(int segment_count)
{
    //printf("size_of_infinity_in_vertices>%d", (segment_count+1)*2);
    return (segment_count+1)*2;
}

static inline void gen_infinity(CPoint* out, float width, float angle, int segment_count)
{
    
    CPoint path[13];
    path[0]=CPointMake(53,23);
    
    path[1]=CPointMake(49,31);
    path[2]=CPointMake(39,47);
    
    path[3]=CPointMake(22,47);
    
    path[4]=CPointMake(6,47);
    path[5]=CPointMake(0,31);
    
    path[6]=CPointMake(0,23);
    
    path[7]=CPointMake(0,16);
    path[8]=CPointMake(5,0);
    
    path[9]=CPointMake(23,0);
    
    path[10]=CPointMake(39,0);
    path[11]=CPointMake(48,15);
    
    path[12]=CPointMake(52,21);
    
    
    
    int offset=0;
    
    int seg;
    for (seg=0; seg<=segment_count; seg++) {
        float tt = ((float)seg/(float)segment_count)*angle;
        
        int q=4;
        float tstep=1./q;
        int n = floor(tt/tstep);
        
        if (seg >= segment_count) {
            //n=n-1;//q-1;
        }
        //printf("n>%d\n", n);
        
        CPoint a = path[0+3*n];;
        CPoint p1 = path[1+3*n];
        CPoint p2 = path[2+3*n];
        CPoint b = path[3+3*n];
        
        float t=(tt-tstep*n)*q;
        float nt = 1.0f - t;
        
        
        vec2 p = {a.x * nt * nt * nt  +  3.0 * p1.x * nt * nt * t  +  3.0 * p2.x * nt * t * t  +  b.x * t * t * t,
            a.y * nt * nt * nt  +  3.0 * p1.y * nt * nt * t  +  3.0 * p2.y * nt * t * t  +  b.y * t * t * t};
        
        vec2 tangent = {-3.0 * a.x * nt * nt  +  3.0 * p1.x * (1.0 - 4.0 * t + 3.0 * t * t)  +  3.0 * p2.x * (2.0 * t - 3.0 * t * t)  +  3.0 * b.x * t * t,
            -3.0 * a.y * nt * nt  +  3.0 * p1.y * (1.0 - 4.0 * t + 3.0 * t * t)  +  3.0 * p2.y * (2.0 * t - 3.0 * t * t)  +  3.0 * b.y * t * t};
        
        vec2 tan_norm = {-tangent[1], tangent[0]};
        vec2 norm;
        vec2_norm(norm, tan_norm);
        
        
        vec2 v;
        vec2 norm_scaled;
        vec2_scale(norm_scaled, norm, +width/2.);
        vec2_add(v, p, norm_scaled);
        
        out[offset] = CPointMake(v[0], v[1]);
        offset++;
        
        vec2_scale(norm_scaled, norm, -width/2.);
        vec2_add(v, p, norm_scaled);
        
        out[offset] = CPointMake(v[0], v[1]);
        offset++;
        
        
        
    }
    
    
    //printf("infinity_q>%d", offset);
    
}

void change_infinity(Shape* shape, float angle)
{
    if ( (*shape).params.var_params.angle != angle )
    {
        
        (*shape).params.var_params.angle = angle;
        
        gen_infinity(shape->data, (*shape).params.var_params.width, (*shape).params.var_params.angle, (*shape).params.const_params.round_count);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        
        glBufferData(GL_ARRAY_BUFFER, shape->num_points*sizeof(CPoint), shape->data, GL_DYNAMIC_DRAW);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
    }
}

Shape create_infinity(float width, float angle, int segment_count, vec4 color)
{
    int real_vertex_count = size_of_infinity_in_vertices(segment_count);
    
    CPoint *data = malloc(sizeof(CPoint)*real_vertex_count);
    
    gen_infinity(data, width, angle, segment_count);
    
    Params params=default_params();
    params.const_params.triangle_mode=GL_TRIANGLE_STRIP;
    
    params.const_params.round_count=segment_count;
    
    
    
    params.var_params.width = width;
    params.var_params.angle = angle;
    
    
    
    return (Shape) {{color[0], color[1], color[2], color[3]},
        data,
        create_vbo(sizeof(data), data, GL_DYNAMIC_DRAW),
        real_vertex_count,
        params};
    
    
}





void draw_infinity(const Shape* shape, mat4x4 view_projection_matrix)
{
    
    if (shape->params.alpha>0 && (fabs(shape->params.scale.x)>0 && fabs(shape->params.scale.y)>0 && fabs(shape->params.scale.z)>0))
    {
        
        mat4x4 model_view_projection_matrix;
        mvp_matrix(model_view_projection_matrix, shape->params, view_projection_matrix);
        
        glUseProgram(color_program.program);
        
        glUniformMatrix4fv(color_program.u_mvp_matrix_location, 1, GL_FALSE, (GLfloat*)model_view_projection_matrix);
        glUniform4fv(color_program.u_color_location, 1, shape->color);
        glUniform1f(color_program.u_alpha_loaction, shape->params.alpha);
        
        glVertexAttribPointer(color_program.a_position_location, 2, GL_FLOAT, GL_FALSE, sizeof(CPoint), &shape->data[0].x);
        glEnableVertexAttribArray(color_program.a_position_location);
        glDrawArrays(shape->params.const_params.triangle_mode, 0, shape->num_points);
        
    }
    
}








static inline int size_of_rounded_rectangle_stroked_in_vertices(int round_count) {
    //return 4*(2+round_count)+2;
    
    //printf("size_of_rounded_rectangle_stroked_in_vertices>%d\n", (2+round_count)*2);
    return 4*(2+round_count)*2+2;
}

static inline void gen_rounded_rectangle_stroked(CPoint* out, CSize size, float radius, float stroke_width, int round_count)
{
    
    //printf("gen_rounded_rectangle> %d \n", round_count);
    int offset=0;
    
    //out[offset++] = CPointMake(0, 0);
    
    float k = M_PI/2/(round_count+1);
    float inner_radius = radius - stroke_width;
    
    int i=0;
    int n=0;
    
    
    int r;
    
    for (i=(round_count+2)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*radius, size.height/2-radius + sin(i*k)*radius);
        
        //r++;
        out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*inner_radius, size.height/2-radius + sin(i*k)*inner_radius);
        //r++;
        //out[offset++] = CPointMake(0, 0);
        //out[offset++] = CPointMake(size.width/2-inner_radius + cos(i*k)*inner_radius, size.height/2-inner_radius + sin(i*k)*inner_radius);
    }
    
    
    //printf("n>%d\n", r);
    n++;
    
    for (i=(round_count+1)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(-size.width/2+radius + cos(i*k)*radius, size.height/2-radius + sin(i*k)*radius);
        
        //out[offset++] = CPointMake(0, 0);
        out[offset++] = CPointMake(-size.width/2+radius + cos(i*k)*inner_radius, size.height/2-radius + sin(i*k)*inner_radius);
    }
    n++;
    
    for (i=(round_count+1)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(-size.width/2+radius + cos(i*k)*radius, -size.height/2+radius + sin(i*k)*radius);
        
        //out[offset++] = CPointMake(0, 0);
        out[offset++] = CPointMake(-size.width/2+radius + cos(i*k)*inner_radius, -size.height/2+radius + sin(i*k)*inner_radius);
    }
    n++;
    
    for (i=(round_count+1)*n; i<=round_count+1 + (round_count+1)*n; i++) {
        out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*radius, -size.height/2+radius + sin(i*k)*radius);
        
        //out[offset++] = CPointMake(0, 0);
        out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*inner_radius, -size.height/2+radius + sin(i*k)*inner_radius);
    }
    n++;
    
    i=0;
    out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*radius, size.height/2-radius + sin(i*k)*radius);
    
    out[offset++] = CPointMake(size.width/2-radius + cos(i*k)*inner_radius, size.height/2-radius + sin(i*k)*inner_radius);
    
    
    
    //out[offset++] = CPointMake(size.width/2, size.height/2-radius);
    
}


Shape create_rounded_rectangle_stroked(CSize size, float radius, float stroke_width, int round_count, vec4 color)
{
    //round_count==10 выпадают полигоны
    int real_vertex_count = size_of_rounded_rectangle_stroked_in_vertices(round_count);
    
    CPoint *data = malloc(sizeof(CPoint)*real_vertex_count*2);
    //CPoint data[real_vertex_count * 2];
    
    Params params = default_params();
    params.const_params.round_count=round_count;
    
    params.var_params.size=size;
    params.var_params.radius=radius;
    params.var_params.width=stroke_width;
    
    //gen_rounded_rectangle(data, size, radius, round_count);
    gen_rounded_rectangle_stroked(data, params.var_params.size, params.var_params.radius, params.var_params.width, params.const_params.round_count);
    
    //gen_rounded_rectangle_stroked(data, params.var_params.size, params.var_params.radius, params.var_params.width, params.const_params.round_count);
    
    params.const_params.triangle_mode = GL_TRIANGLE_STRIP;
    return (Shape) {{color[0], color[1], color[2], color[3]},
        data,
        create_vbo(sizeof(data), data, GL_DYNAMIC_DRAW),
        real_vertex_count,
        params};
}

void change_rounded_rectangle_stroked(Shape* shape, CSize size, float radius, float stroke_width)
{
    
    if ((*shape).params.var_params.size.width != size.width || (*shape).params.var_params.size.height != size.height || (*shape).params.var_params.radius != radius )
    {
        //DEBUG_LOG_WRITE_D("fps","change_rounded_rectangle");
        
        (*shape).params.var_params.size.width = size.width;
        (*shape).params.var_params.size.height = size.height;
        (*shape).params.var_params.radius = radius;
        
        gen_rounded_rectangle_stroked((*shape).data, (*shape).params.var_params.size, (*shape).params.var_params.radius, (*shape).params.var_params.width, (*shape).params.const_params.round_count);
        //gen_rounded_rectangle(shape->data, (*shape).params.var_params.size, (*shape).params.var_params.radius*0+21, (*shape).params.const_params.round_count);
        
        glBindBuffer(GL_ARRAY_BUFFER, shape->buffer);
        glBufferSubData(GL_ARRAY_BUFFER, 0, shape->num_points*sizeof(CPoint), shape->data);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    
}