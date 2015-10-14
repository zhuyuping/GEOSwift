Pod::Spec.new do |s|

  s.name         = "GEOSwift"
  s.version      = "0.2.1"
  s.summary      = "The Swift Geographic Engine."

  s.description  = <<-DESC
Easily handle a geographical object model (points, linestrings, polygons etc.) and related topographical operations (intersections, overlapping etc.). 
A type-safe, MIT-licensed Swift interface to the OSGeo's GEOS library routines, nicely integrated with MapKit, Mapbox, Quicklook.
DESC

  s.homepage     = "https://github.com/andreacremaschi/GEOSwift"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Andrea Cremaschi" => "andreacremaschi@libero.it" }
  s.social_media_url   = "http://twitter.com/andreacremaschi"
  s.platform     = :ios, "8.0"
  #s.source       = { :git => "https://github.com/andreacremaschi/GEOSwift.git", :tag => "0.2.1" }
  #s.resource = "geos/lib/*.dylib"
  s.source       = { :git => "https://github.com/andreacremaschi/GEOSwift.git", :branch => "feature/embed-geos-dylib" }
   
  s.subspec 'Core' do |cs|
    cs.source_files = "GEOSwift/*.{swift,m}", "geos/include/geos_c.h" #'geos/geos_svn_revision.h', 
    cs.vendored_libraries = "geos/lib/libgeos_c.dylib", "geos/lib/libgeos.dylib"
    #cs.resources = "geos/lib/*.dylib"
    #cs.xcconfig = { 'LD_RUNPATH_SEARCH_PATHS' => '@loader_path/../Frameworks' }
    # cs.preserve_paths = 'geos/include/**/*.{h,inl,in}'
    cs.public_header_files = "geos/include/geos_c.h"
      
    #cs.dependency "geos", "~> 3.4.2"
  end

  # s.subspec 'MapboxGL' do |cs|
  #   cs.source_files = "GEOSwift/MapboxGL"
  #   cs.dependency "GEOSwift/Core"
  #   cs.dependency "Mapbox-iOS-SDK"
  # end

  s.default_subspec = 'Core'

end
