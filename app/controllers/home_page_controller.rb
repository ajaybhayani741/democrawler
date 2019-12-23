class HomePageController < ApplicationController
    require 'nokogiri'
    require 'open-uri'
    def index
    end
    
    def sitemap
        url = params[:url]
        page = Nokogiri::HTML(open(url))
        rows = page.css('a')
        hlink={}
        if rows.present?
            rows[1..-2].each do |row|
                hrefs = rows.map{ |a| a['href'] }.compact.uniq
                hrefs.each do |href|
                    href = href.match("^/").present? ? href.delete_prefix('/') : href
                    if href.split("/")[1].present?
                        if hlink[href.split("/")[0]].present?
                            hlink[href.split("/")[0]] << href.split("/")[1] if !hlink[href.split("/")[0]].include? href.split("/")[1]
                        else
                            hlink = hlink.merge(href.split("/")[0]=> [href.split("/")[1]])
                        end
                    else
                        hlink = hlink.merge(href.split("/")[0]=> []) if !href.start_with?('https://', 'http:') && href.present?
                    end
                end # done: hrefs.each
            end # done: rows.each
        end
        render json: {'links': {url=> hlink}}
    end
end
