# get all package names
grep -o '<a href=\"http://hackage\.haskell\.org\/[^\/]*\/[^\/]*\"' All\ packages\ by\ name\ _\ Hackage.html | sed 's/<a href=//g' | sed 's/\"//g'

# get github url (if exists)
grep -o '<a href=https\?:\/\/github\.com.*>' | sed 's/<a href=//g' | sed 's/>//g'

# get mentioned packages
grep -o '<a href=\"\/package\/[^\/]*[^0-9]\">' | sed 's/<a href=\"//g' | sed 's/\">//g'


echo 'http://hackage.haskell.org/package/zero\nhttp://hackage.haskell.org/package/zerobin\nhttp://hackage.haskell.org/package/xss-sanitize' | xargs -L1 -J "curl % | tee >(grep -o '<a href=https\?:\/\/github\.com.*>' | sed 's/<a href=//g' | sed 's/>//g') | grep -o '<a href=\"\/package\/[^\/]*[^0-9]\">' | sed 's/<a href=\"//g' | sed 's/\">//g'"


curl http://hackage.haskell.org/package/xss-sanitize | tee >(grep -o '<a href=\"\/package\/[^\/]*[^0-9]\">' | sed 's/<a href=\"//g' | sed 's/\">//g') | grep -o '<a href=https\?:\/\/github\.com.*>' | sed 's/<a href=//g' | sed 's/>//g' 


echo 'http://hackage.haskell.org/package/zero\nhttp://hackage.haskell.org/package/zerobin\nhttp://hackage.haskell.org/package/xss-sanitize' | while read line; do curl $line | tee >(grep -o '<a href=\"\/package\/[^\/]*[^0-9]\">' | sed 's/<a href=\"//g' | sed 's/\">//g') | grep -o '<a href=https\?:\/\/github\.com.*>' | sed 's/<a href=//g' | sed 's/>//g' ; done

grep -o '<a href=\"http://hackage\.haskell\.org\/[^\/]*\/[^\/]*\"' All\ packages\ by\ name\ _\ Hackage.html | sed 's/<a href=//g' | sed 's/\"//g' | while read line; do curl $line | tee >(grep -o '<a href=\"\/package\/[^\/]*[^0-9]\">' | sed 's/<a href=\"//g' | sed 's/\">//g') | grep -o '<a href=https\?:\/\/github\.com.*>' | sed 's/<a href=//g' | sed 's/>//g' >> allpacks.txt ; done

grep -o '<a href=\"http://hackage\.haskell\.org\/[^\/]*\/[^\/]*\"' All\ packages\ by\ name\ _\ Hackage.html | sed 's/<a href=//g' | sed 's/\"//g' | while read line; do curl $line | tee >(tee -a test.txt) >(grep -o '<a href=\"\/package\/[^\/]*[^0-9]\">' | sed 's/<a href=\"//g' | sed 's/\">//g' | tee -a test.txt) | grep -o '<a href=https\?:\/\/github\.com.*>' | sed 's/<a href=//g' | sed 's/>//g' | tee -a test.txt ; done


# get lines, returning the github acct., dependencies, and package name
| while read line; do echo $line | tee -a text.txt; curl $line | tee >(((grep -o '<a href=\"\/package\/[^\/]*[^0-9]\">' | sed 's/<a href=\"//g' | sed 's/\">//g') ; echo $line ; echo '') | tee -a test.txt) | grep -o '<a href=https\?:\/\/github\.com.*>' | sed 's/<a href=//g' | sed 's/>//g' | tee -a test.txt ; done

Copied package list at top to other file



