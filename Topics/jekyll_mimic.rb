
class Page
    include Convertible
    attr_writer :dir
    attr_accessor :site,:pager
    attr_accessor :name,:ext,:basename
    attr_accessor :data,:content,:output

    def initalize(site, base, dir, name)
        @site = site
        @base = base
        @dir = dir
        @name = name

        self.process(name)
        self.read_yaml(File.join(base,dir),name)
    end
    def dir
    end
    def template
    end
    # generated relative url of this page e.g /about.html
    def url
    end
    def process(name)
        self.ext = File.extname(name)
        self.basename = name[0..-self.ext.length-1]
    end
    #add any necessary layouts to this post
    def render(layouts, site_payload)
        payload = {
            'page' => self.to_liquid,
            'paginator' => pager.to_liquid
        }.deep_merge(site_payload)

        do_layout(payload,layouts)
    end
    # convert the page's data to a hash suitable for use by liquid
    def to_liquid
        self.data.deep_merge({
            'url' => File.join(@dir, self.url),
            'content' => self.content
            })
    end

    def destination(dest)
    end

end

module Convertible
    def to_s
    end
    def read_yaml(base,name)
    end
    # transform the contents based on the content type
    def transform
    end
    # determine the extension depending on content_type
    def output_ext
    end
    # determine which converter to use based n this convertible's content extension
    def converter
    end
    # add any necessary layouts to this convertible document
    def do_layout(payload, layouts)
    end
end


#site.rb
module Jekyll
    class Site
        attr_accessor: :config, :layouts, :posts, :pages #other

        attr_accessor: :converters, :generators


        def initialize(config)
            self.config = config.clone

            self.safe
            self.source = File.expand_path(config['source'])
            self.dest
            self.plugins
            self.lsi
            self.pygments
            self.permalink_style
            self.exclude
            self.include
            self.future
            self.limit_posts

            self.reset
            self.setup
        end

        def process
            self.reset
            self.read
            self.generate
            self.render
            self.cleanup
            self.write
        end

        # reset site details
        # 如每次监控变化时候，process中无setup
        def reset
            self.time
            self.layouts = {}
            self.posts = []
            self.static_files = []
            self.categories = Hash.new {|hash, key| hash[key] = []}
            self.tags = Hash.new {|hash, key| hash[key] = []}

            if !self.limit_posts.nil? && self.limit_posts < 1
                raise ArgumentError, ''
            end
        end
        # setup
        # load necessary libraries, plugins, converters, and generators
        def setup
            require 'classifier' if self.lsi

            unless self.safe
                self.plugins.each do |plugins|
                    Dir[File.join(plugins, "**/*.rb")].each do |f|
                        require f
                    end
            end

            self.converters = Jekyll::Converter.subclasses.select do |c|
                !self.safe || c.safe
            end.map do |c|
                c.new(self.config)
            end

            self.generators = [] # the same processing method
        # read
        # read site data from disk and load it into internal data structures
        def read
            self.read_layout
            self.read_directories
        end
        # read_layout
        # read all the files in <source>/<layout> and create a new Layout object
        
        
        # read_directories
        # recursively traverse directories to find posts, pages and static files
        # that will become part of the site according to the rules in filter_entries
        

        # read_posts
        # read all the files in <source>/<dir>/_posts and create a new Post object with each one
        
        # run each of generators 
        # 如pagination 分页#
        # generate
        def generate
            self.generators.each do |generator|
                generator.generate(self)
            end
        end

        # render
        # render the site to the destination
        def render
            payload = site_payload
            
            self.posts.each do |post|
                post.render(self.layouts, payload)
            end

            self.pages.each do |page|
                page.render(self.layouts, payload)
            end

            self.categories.values.map { |ps| ps.sort! {|a,b| b <=> a} }
            self.tags.values.map { |ps| ps.sort! {|a,b| b <=> a} }
        end

        # cleanup
        # remove orphand files and empty directories in destination
        
        
        # write
        # write static files, pages and posts
        def write
            self.posts.each do |post|
                post.write(self.dest)
            end
            self.pages.each do |post|
                post.write(self.dest)
            end
            self.static_files.each do |post|
                post.write(self.dest)
            end


        # post_attr_hash
        # site_payload
        #  the hash payload containing site-wide data geted for self[site object]
        def site_payload
            {"site" => self.config.merge({
                "time":
                "posts":
                "pages":
                "html_pages"
                "categories"
                "tags"
                })}
        end
        # filter_entrites
        # getConvertImpl


# look the page lifecycle
entries = scanDirectory() do
      entries.each do |f|
        if Post.valid?(f)
          post = Post.new(self, self.source, dir, f)

          if post.published && (self.future || post.date <= self.time)
            self.posts << post
            post.categories.each { |c| self.categories[c] << post }
            post.tags.each { |c| self.tags[c] << post }
          end
        end
      end
end

post.render(self.layouts, payload)
post.write(self.dest)

# 如何渲染
# 每个post和page可以指明一个layout -》 post.layout
# 然后layout对象， 是在遍历_layout文件夹生成的，仅仅包含相应的template_html
# 渲染的时候，需要从target的layout属性指到父layout，父layout同样，如果有爷爷辈layout的话
# 同时每个page或post的include，也是需要指定到具体的page的。
# 指定后，可以把相应的template_html最终包含到target的html中！
# page && static_files

if first3 == "---"
    pages << Page.new(self, self.source, dir, f)
else
    static_files << StaticFile.new(self, self.source, dir, f)

#Layout
class Layout
    include Convertible

    attr_reader :site
    attr_accessor :ext, :data, :content

    def initialize(site, base, name)
        @site
        @base
        @name

        self.data = {}
        self.process(name)
        self.read_yaml(base, name)
    end

    def read_yaml(base,name)
        self.content = File.read(File.join(base,name))

        begin
            if self.content = //m
                self.content = $POSTMATCH
                self.data = YAML.load($1)
            end
        rescue => e
            puts ''
        end

        self.data ||= {}
    end

    # extract info from the layout filename
    def process
        self.ext = File.extname(name)
    end
end

# page 和 post 的 实例化流程和layout差不多 process下， read_yaml下
#Page
class Page

    def render(layouts, site_payload)
        payload ={
            "page" => self.to_liquid,
            "paginator" => pager.to_liquid
        }.deep_merge(payload)
        # payload structure {'page'=> dict, 'site'=>dict, paginator => dict}

        do_layout(payload, layouts)
    end

    # convert this page's data to a hash suitable for use by Liquid
    def to_liquid
        self.data.deep_merge({
            "url" => File.join(@dir, self.url),
            "content" => self.content
            })
    end

    # do_layout方法是写在convertible 模块中后，被mixin到Page类中的
    #add any neccessary layouts to this convertible document
    def do_layout(payload, layouts)
        info = {}
        payload['pygments_prefix'] = converter.pygments_prefix
        payload['pygments_suffix'] = converter.pygments_suffix

        begin
            self.content = Liquid::Template.parse(self.content).render(payload,info)
        rescue => e
            puts ""
        end

        self.transform

        self.output = self.content

        # recursively render layouts
        layout = layouts[self.data["layout"]]
        used = Set.new([layout])

        # 精彩！！ 
        while layout
            payload = payload.deep_merge({
                "content" => self.output,
                "page" => layout.data
                }) # content就是写layout的时候，预留才{{ content }} 和普通的变量一样，所以可以通过local variables传入render交给 template render引擎去渲染

            begin
                self.output = Liquid::Template.parse(layout.content).render(payload, info)
            rescue => e
                puts "Liquid Exception : {e.message}} in #{self.data["layout"]}"
            end

            if layout = layout[layout.data["layout"]]
                if used.include?(layout)
                    layout = nil
                else
                    used << layout
        end
    end

    def write(dest)
        path = destination(dest)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "w") { |f| f.write(self.output) }
    end
end
#Post

# 理解liquid
#Liquid is an extraction from the e-commerce system Shopify. Shopify powers many thousands of e-commerce stores which all call for unique designs.
#It was developed for usage in Ruby on Rails web applications and integrates seamlessly as a plugin but it also works excellently as a stand alone library.
Liquid::Template.parse(template).render 'products' => Product.find(:all)
