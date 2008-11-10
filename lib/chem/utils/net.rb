# Copyright (C) 2005, 2006 KADOWAKI Tadashi <tadakado@gmail.com>
#                          TANAKA   Nobuya  <nobuya.tanaka@gmail.com>
#                          APODACA  Richard <r_apodaca@users.sf.net>

require 'net/http'
require 'net/ftp'
require 'date'
require 'rexml/document'
require 'cgi'

module Chem

  module NetUtils

    def http_get(str)
      Net::HTTP.get(URI.parse(str))
    end

  end

  def self.search_net(term, options)
    case options[:db]
    when :pubmed
      Chem::NCBI::ESearch.query(term, options)
    when :pubchem
      Chem::NCBI::ESearch.query(term, options)
    end
  end

  class NCBI
    EUtilsURI  = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
    PubChemURI = 'http://pubchem.ncbi.nlm.nih.gov/'

    # EInfo
    module EInfo
      extend Chem::NetUtils

      EInfoURI = EUtilsURI + 'einfo.fcgi?'

      def self.query(params = {})
        if params.empty?
          xml = REXML::Document.new(http_get(EInfoURI))
          dbs = []
          xml.elements.each("eInfoResult/DbList/DbName") do |element|
            dbs << element.text
          end
          dbs
        elsif params[:db]
          DbInfo.new(REXML::Document.new(http_get(EInfoURI + "db=" + params[:db].to_s)))
        end
      end

      class DbInfo
        attr_reader :db_name, :menu_name, :description, :count, :last_update
        def initialize(xml)
          @db_name     = xml.elements["eInfoResult/DbInfo/DbName"].text
          @menu_name   = xml.elements["eInfoResult/DbInfo/MenuName"].text
          @description = xml.elements["eInfoResult/DbInfo/Description"].text
          @count       = xml.elements["eInfoResult/DbInfo/Count"].text
          @last_update = xml.elements["eInfoResult/DbInfo/LastUpdate"].text
          @fields = []
          xml.elements.each("eInfoResult/DbInfo/FieldList/Field") do |element|
            @fields << {
              :name         => element.elements["Name"       ].text,
              :full_name    => element.elements["FullName"   ].text,
              :description  => element.elements["Description"].text,
              :term_count   => element.elements["TermCount"  ].text,
              :is_date      => element.elements["IsDate"     ].text == "Y",
              :is_numerical => element.elements["IsNumerical"].text == "Y",
              :single_token => element.elements["SingleToken"].text == "Y",
              :hierarchy    => element.elements["Hierarchy"  ].text == "Y",
              :is_hidden    => element.elements["IsHidden"   ].text == "Y",
            }
          end
        end
      end
      
    end # EInfo module

    module ESearch
      extend Chem::NetUtils

      ESearchURI = EUtilsURI + 'esearch.fcgi?'

      def self.search(params)
        result = {}
        uri = ESearchURI + params.collect{|key, value| key.to_s + "=" + CGI.escape(value.to_s)}.join("&")
        doc = http_get(uri)
        xml = REXML::Document.new(doc)
        raise "Error no result" unless xml.elements["eSearchResult/ERROR"].nil?

        result[:count]     = xml.elements["eSearchResult/Count"   ].text.to_i
        result[:retmax]   = xml.elements["eSearchResult/RetMax"  ].text.to_i
        result[:retstart] = xml.elements["eSearchResult/RetStart"].text.to_i
        
        result[:id_list] = list = []
        xml.elements.each("eSearchResult/IdList/Id") do |element|
          list << element.text.to_i
        end
        result
      end

    end

    module PCFetch

      extend Chem::NetUtils

      PCFetchURI = PubChemURI + 'pc_fetch/pc_fetch.cgi?'

      def self.fetch(params)
        raise "You need to specify :retmode" if params[:retmode].nil?

        uri = PCFetchURI + params.collect{|key, value| key.to_s + "=" + value.to_s}.join("&")
        doc = http_get(uri)
        num = 0
        if m = /pubchem\/\.fetch\/(\d+).sdf/.match(doc)
          puts 'ftp'
          num = m[1].to_i
        elsif m = /reqid=(\d+)/.match(doc)
          puts 'http'
          num = m[1].to_i
        else
          raise "Cannot retrieve file"
        end

        params[:localfilename] ||= "%s%d.sdf" % [params[:db], params[:id]]

        begin
          ftp = Net::FTP.open("ftp.ncbi.nih.gov")
          ftp.login
          ftp.gettextfile("pubchem/.fetch/%d.sdf" % num, params[:localfilename])
        rescue Net::FTPPermError
          puts "error : num"
          retry
        end

      end

    end

    module ESummary

      extend Chem::NetUtils
      ESummaryURI = EUtilsURI + 'esummary.fcgi?'

      def self.get(params)
        uri = ESummaryURI + params.collect{|key, value| key.to_s + "=" + value.to_s}.join("&")
        http_get(uri)
      end

      def self.get_parsed(params)
        tree = {}
        xml = REXML::Document.new(get(params))
        xml.elements.each("eSummaryResult/DocSum/Item") do |element|
          tree[element.attributes["Name"]] =
            case element.attributes["Type"]
            when "String"
              element.text
            when "Integer"
              element.text.to_i
            when "Date"
              element.text
            when "List"
              ary = []
              element.elements.each("Item"){|el|
              ary << case el.attributes["Type"]
                     when "String"
                       el.text
                     when "Integer"
                       el.text.to_i
                     else
                       ""
                     end
            }
              ary
            end
        end
        tree
      end
    end

    # obsolete
    class EFetch

      include Chem::NetUtils

      EFetchURI  = EUtilsURI + 'efetch.fcgi' + '?'

      def initialize(query_key, web_env)
        uri = [PCFetchURI]
        uri << 'db=pccompound'
        uri << '&WebEnv=' + web_env
        uri << '&query_key=' + query_key
        uri << '&retmode=sdf'
        uri << '&compression=none'
        #"retmode=xml&"
        #uri = EFetchURI + "&db=pccompound&retmode=xml&WebEnv=" + web_env + "&query_key=" + query_key + "&tool=oscar3&email=nobuya.tanaka%40gmail.com"
        p uri.join
        doc = http_get(uri.join)
        if m = /bookmarking this page or by going to<\/p><p><a href=\"([^"]+)/.match(doc)
          sleep 1
          p m[1]
          d = http_get(m[1])
          m = /"ftp:\/\/([^"]+)/.match(d)
          p m[1]
          require 'net/ftp'
          begin
            sleep 0.5
            ftp = Net::FTP.open("ftp.ncbi.nih.gov")
            ftp.login
            ftp.gettextfile("pubchem/.fetch/606874731181068179.sdf")
          rescue Net::FTPPermError
            sleep 1
            puts 'OK'
          end
            
        end
      end

      def self.fetch_all(query_key, web_env)
        new(query_key, web_env)
      end

    end

  end
end

if __FILE__ == $0
  # search PubChem compounds using InChI
  query = {
    :db   => :pccompound,
    :term => '"InChI=1/C9H8O4/c1-6(10)13-8-5-3-2-4-7(8)9(11)12/h2-5H,1H3,(H,11,12)/f/h11H"'
  }
  
  p Chem::NCBI::ESearch.search(query)

  # search PubChem substance with term

  query = {
    :db   => "pcsubstance",
    :term => 'benzene'
  }

  p Chem::NCBI::ESearch.search(query)

  # search PubChem substance with complete synonyms

  query = {
    :db    => "pcsubstance",
    :term  => 'benzene',
    :field => 'CSYN',
  }

  p Chem::NCBI::ESearch.search(query)

  # search PubMed
  query = {
    :db   => "pubmed",
    :term => "asthma[mh]+OR+hay+fever[mh]",
  }

  p query
  p Chem::NCBI::ESearch.search(query)

  # Retrieving more entries

  query = {
    :db         => "pubmed",
    :term       => "cancer",
    :reldate    => 60,
    :datetype   => "edat",
    :retmax     => 100,
    :retstart   => 300,
  }

  p Chem::NCBI::ESearch.search(query)

  # Retrieving Eutils database information
  p  Chem::NCBI::EInfo.query


  # Rerieving information about PubChem Compounds

  pp Chem::NCBI::EInfo.query(:db => :pccompound)

  # Retrieving pccompound using PC_Fetch
  # Not recommended
  # It seems that EFetch does not accept db=pccompound
  # PCFetch could be alternatives for EFetch.

  100.upto(110) do |n|
    puts n
    Chem::NCBI::PCFetch::fetch({:db => :pccompound, :id => n, :retmode => :sdf})
  end

  # Retrieving parsed summary for entries
  # CID:100 
  p Chem::NCBI::ESummary::get_parsed({:db => :pccompound, :id => 100})

end

