# FuzzyRecord.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyRecord

  attr_accessor *[:projectRoot,
                  :filePath, :filePaths,
                  :scmStatus, :scmName,
                  :codeObjectName, :codeObjectNames,
                  :matchedRanges]

  def self.recordsWithProjectRoot(theProjectRoot)
    records = []
    Dir[theProjectRoot + "/**/*"].each do |filename|
      next unless File.file?(filename)
      filename.gsub!(/^#{theProjectRoot}\//, '')
      # TODO: Store ignore directories, files in preferences
      next if filename.match(/^(build|tmp|log|vendor)/)
      records << FuzzyRecord.alloc.initWithProjectRoot(theProjectRoot,
                                                       filePath:filename)
    end
    records
  end

  def initWithProjectRoot(theProjectRoot, filePath:theFilePath)
    @projectRoot = theProjectRoot
    @filePath = theFilePath
    @matchedRanges = []
    self
  end

  ##
  # Finds "a/b/c" in "armadillo/bacon/cheshire"
  # Returns an Array of NSRange objects identifying the matches.

  def fuzzyInclude?(searchString)
    # TODO: Search other things like date, classes, or SCM status
    filePathCharIndex = 0
    searchStringCharIndex = 0
    matchIsInProcess = false
    matchingRanges = []
    @matchedRanges = nil
    @matchScore = nil
    
    filePath.each_char do |c|
      if (c &&
          searchString[searchStringCharIndex] &&
          c.upcase == searchString[searchStringCharIndex].upcase)
        if matchIsInProcess
          lastRange       = matchingRanges.lastObject
          lastObjectIndex = matchingRanges.indexOfObjectIdenticalTo(lastRange)
          matchingRanges[lastObjectIndex] = NSMakeRange(lastRange.location,
                                                        lastRange.length + 1)
        else
          matchingRanges << NSMakeRange(filePathCharIndex, 1)
        end
        matchIsInProcess = true
        searchStringCharIndex += 1
      else
        matchIsInProcess = false
      end
      filePathCharIndex += 1
    end
    # Reject partial matches
    return nil if searchStringCharIndex < searchString.length

    if matchingRanges.length > 0
      @matchedRanges = matchingRanges
      return true
    end
    nil
  end

  def matchScore
    @matchScore ||= @matchedRanges.inject(0) {|memo, element|
      memo + element.location }
  end

  def modifiedAt
    @modifiedAt ||= begin
                      NSFileManager.defaultManager.
                        attributesOfItemAtPath(absFilePath,
                                               error:nil)[NSFileModificationDate]
                    end
  end

  def absFilePath
    File.join(projectRoot, filePath)
  end

end

