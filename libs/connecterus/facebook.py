import os
import facebookinsights as fi

FACEBOOK_INSIGHTS_CLIENT_ID="686274374891992"
FACEBOOK_INSIGHTS_CLIENT_SECRET="efe16931258d0fe2dfc30cb9a86573d7"

SG_FACEBOOK_INSIGHTS_CLIENT_ID="686274374891992"
SG_FACEBOOK_INSIGHTS_CLIENT_SECRET="efe16931258d0fe2dfc30cb9a86573d7"

SG_TOKEN = "EAACEdEose0cBAGV6bvokHPwUNPysZA2y4L62XDUTuqjkqndtkYBXdVLcfZBXdaV40we8ZAvGuF8u8NPuyY9zuIvM5WlABTrUHK2DZBmHQOc8Y0s2ZAWjJKXww3usZBfL9K2NnIO2Nmggq3VPrh93CTA9YPPKEi3z6CXlMZAyEeSF7LpeKuZAl9pV"
PAR_TOKEN = "EAACEdEose0cBAAUfA91PIl8Rx9aEJDHdwQNSVI3w5k8HUcZCvB1nPkIWxg0dsETELua7jZBHJY4euP5Smp0XkwwMZBYYmTS5qwxATtbjBcwp4ytwQIdvyF086XZAacU84RcddKAB6ZCwAV60q3MbwJveNiZCghN1voZCLWMFZA0bdexr2hyZCbAm4fHDNOGecFC0ZD"
print("aa")
# prompt for credentials on the command-line,
# get access to one or more pages
#page = fi.authenticate(
#FACEBOOK_INSIGHTS_CLIENT_ID,FACEBOOK_INSIGHTS_CLIENT_SECRET
#)
# alternatively, pass an existing page token
#page = fi.authenticate(token=os.environ['FACEBOOK_PAGE_TOKEN'])
page = fi.authenticate(token=SG_TOKEN)
print("aa2")
# return a range of page posts
latest = page.posts.latest(10).get()
today = page.posts.range(days=1).get()
quarter = page.posts.range(months=3).get()

print(latest)