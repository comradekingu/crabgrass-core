#= PathFinder::FindByPath
#
#:include:EXAMPLES
#

module PathFinder
  module FindByPath
    # For path see ParsedPath.
    # For options see Options.
    def find_by_path(path, options = {})
      query(path, options).find
    end

    # For path see ParsedPath.
    # For options see Options.
    # Additionally accepts options :page and :per_page.
    # We are paginating pages, so the term page is ambiguous. In options, :page
    # and :per_page are used for pagination, and don't refer to the type of pages
    # that we are finding.
    def paginate_by_path(path, options = {}, pagination_options = {})
      query(path, options.merge(pagination_options)).paginate
    end

    # For path see ParsedPath.
    # For options see Options.
    def count_by_path(path, options = {})
      query(path, options).count
    end

    # For path see ParsedPath.
    # For options see Options.
    def ids_by_path(path, options = {})
      query(path, options).ids
    end

    # construct_finder_sql is private, but we would like to be able to use it
    # in the builders.
    # def find_ids(options)
    #  self.connection.select_values construct_finder_sql(options)
    # end

    private

    def query(path, options)
      query_method  = options[:method] || :mysql
      query_options = resolve_options(query_method, path, options)
      PathFinder.get_query(query_method).new(path, query_options, self)
    end

    def resolve_options(query_method, path, options)
      if options[:callback]
        path = PathFinder::ParsedPath.new(path)
        PathFinder.get_options_module(query_method).send(options[:callback], path, options)
      else
        options
      end
    end

    # def resolve_method(options)
    #  options[:method] ||= :mysql
    #  if !ThinkingSphinx.updates_enabled? and options[:method] == :sphinx
    #    options[:method] = :mysql
    #  end
    #  options[:method]
    # end
  end # FindByPath
end # PathFinder
