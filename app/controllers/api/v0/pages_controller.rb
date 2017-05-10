class Api::V0::PagesController < Api::V0::ApiController
  def index
    query = page_collection
    paging = pagination(query)
    pages = query.order(updated_at: :desc).limit(paging[:page_items]).offset(paging[:offset])

    render json: {
      links: paging[:links],
      data: pages
    }
  end

  def show
    page = Page.find(params[:id])
    render json: {
      data: page.as_json(include: { versions: { methods: :current_annotation } })
    }
  end

  protected

  def paging_path_for_page(*args)
    api_v0_pages_path(*args)
  end

  def page_collection
    collection = Page.all
    collection = collection.where(site: params[:site]) if params[:site]
    collection = collection.where(agency: params[:agency]) if params[:agency]
    if params[:url]
      query = params[:url]
      if query.include? '*'
        query = query.gsub('%', '\%').gsub('_', '\_').tr('*', '%')
        collection = collection.where('url LIKE ?', query)
      else
        collection = collection.where(url: query)
      end
    end
    collection
  end
end
