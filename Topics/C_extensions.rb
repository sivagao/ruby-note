# writing your C extensions
# Excerpted from "Working With Unix Processes"

#spyglass/ext/extconf.rb
require 'mkmf'
dir_config("spyglass_parser")
have_library("c", "main")
create_makefile("spyglass_parser")

# used in lib/spyglass.rb
require 'spyglass_parser'

# compile
$ ruby extconf.rb #creating Makefile
$ make #构建扩展文件
# using rake-compiler， Rake::ExtensionTask
Rake::ExtensionTask.new('spyglass_parser')
$ rake compile
# 内幕看源代码
#http://rake-compiler.rubyforge.org/Rake/ExtensionTask.html#method-i-source_files

# the c file 
=begin
#include "ruby.h" //头文件，获得所需的ruby定义
// 每个扩展都有名为Init_name的C全局函数，这个函数在解释器第一次加载名为name的扩展被调用
// 用来初始化扩展，加入到当前Ruby环境中
void Init_my_test(){
    cTest = rb_define_class("MyTest", rb_cObject);
    rb_define_method(cTest,"initialize",t_init, 0);
    rb_define_method(cTest,"add",t_add,1);
    id_push = rb_intern("push");
}
=end


# the counterpart ruby file, 
# which is plug compatible
class MyTest
    def initialize
        @arr = Array.new
    end
    def add(obj)
        @arr.push(obj)
    end
end