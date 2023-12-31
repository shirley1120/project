setwd("C:/Users/USER/Downloads")
fb <- read.csv("hw6-fb.csv")
library(tidyverse)
library(ggplot2)
attach(fb)

names(fb)
str(fb)
fb$gender <- as.factor(gender)
fb$visit_date <- as.Date(visit_date)
fb$condition <- as.factor(condition)

#資料分析
summary(fb)
fb1 <- fb %>% 
  group_by(condition) %>%
  summarise(mean_spent_sec=mean(time_spent_homepage_sec),
            article.n=sum(clicked_article),
            like.n=sum(clicked_like),
            share.n=sum(clicked_share))

fb1 = as.matrix(fb1[,3:5])
b1 <- barplot(fb1, names.arg=c('article','like','share'), col=c("pink","lightblue"), 
              xlab="clicked object", ylab="times", ylim=c(0,10000),beside=T, 
              legend.text=c('tip','tool'),main="兩種文章各項點擊次數比較圖")
text(b1,labels=fb1,y=2,pos=3,offset=1.2,cex=0.8)

fb2 <- fb %>% 
  group_by(visit_date,condition) %>%
  mutate(total_sec=sum(time_spent_homepage_sec))

ggplot(fb2, aes(x = visit_date, y = total_sec, colour = condition)) + 
  geom_point() + geom_line() +
  xlab("Date") + ylab("total sec") +
  ggtitle(label="daily viewing time") +
  theme_bw()

#group
table(condition,gender)
fb_tip <- fb %>% filter(fb$condition=="tips")
fb_tool <- fb %>% filter(fb$condition=="tools")

#tips
fb_tip %>% 
  group_by(gender) %>%
  summarise(clicked_article_rate=sum(clicked_article)/n(),
            clicked_like_rate=sum(clicked_like)/n(),
            clicked_share_rate=sum(clicked_share)/n())
fb_tip %>% 
  group_by(gender) %>%
  summarise(mean_time_spent_homepage_sec=mean(time_spent_homepage_sec))

#tools
fb_tool %>% 
  group_by(gender) %>%
  summarise(clicked_article_rate=sum(clicked_article)/n(),
            clicked_like_rate=sum(clicked_like)/n(),
            clicked_share_rate=sum(clicked_share/n()))
fb_tool %>% 
  group_by(gender) %>%
  summarise(mean_time_spent_homepage_sec=mean(time_spent_homepage_sec))

#anova
#檢定網頁停留時間與什麼變數顯著
aov1 <- aov(time_spent_homepage_sec ~ ., fb) #皆不顯著
aov2 <- aov(clicked_article~ ., fb) #皆不顯著
aov3 <- aov(clicked_like ~ ., fb) #Pvisit_date, condition顯著
aov4 <- aov(clicked_share ~ ., fb) #Pcondition顯著

summary(aov1)
summary(aov2)
summary(aov3)
summary(aov4)

#chi squared test 獨立性檢定
chisq.test(fb$visit_date,fb$condition)
chisq.test(fb$clicked_like,fb$condition)

#依文章和性別分組，計算案讚比例與分享比例
fb1 <- fb %>% 
  group_by(condition,gender) %>%
  summarise(clicked_article_rate=sum(clicked_article)/n()*100,
            clicked_like_rate=sum(clicked_like)/n()*100,
            clicked_share_rate=sum(clicked_share)/n()*100)

ggplot(fb1, aes(x=gender,y=clicked_like_rate,fill=gender))+
  geom_col()+
  geom_text(aes(label=paste0(round(clicked_like_rate,2),"%")),vjust=1.5,size=3.1)+
  ylab("clicked_like_rate(%)")+
  facet_wrap(~condition)+
  scale_fill_brewer(palette = "Pastel1")

ggplot(fb1, aes(x=gender,y=clicked_share_rate,fill=gender))+
  geom_col()+
  geom_text(aes(label=paste0(round(clicked_share_rate,2),"%")),vjust=1.5,size=3.1)+
  ylab("clicked_share_rate(%)")+
  facet_wrap(~condition)+
  scale_fill_brewer(palette = "Pastel1")

#分組中各性別按讚比例與分享比例是否有顯著差異
fbb <- fb %>% 
  group_by(condition,gender) %>% 
  summarise(like_n=sum(clicked_like),
            share_n=sum(clicked_share),
            count=n())

tip.like.n = as.numeric(fbb[1:4,3]$like_n)
tip.count = as.numeric(fbb[1:4,5]$count)
prop.test(tip.like.n,tip.count)

tip.share.n = as.numeric(fbb[1:4,4]$share_n)
tip.count = as.numeric(fbb[1:4,5]$count)
prop.test(tip.share.n,tip.count)

tool.like.n = as.numeric(fbb[5:8,3]$like_n)
tool.count = as.numeric(fbb[5:8,5]$count)
prop.test(tool.like.n,tool.count)

tool.share.n = as.numeric(fbb[5:8,4]$share_n)
tool.count = as.numeric(fbb[5:8,5]$count)
prop.test(tool.share.n,tool.count)

#兩種文章按讚比例是否顯著不同
fbf <- fb %>% 
  group_by(condition) %>% 
  summarise(like_n=sum(clicked_like), count=n())

like.n = as.numeric(fbf$like_n)
count = as.numeric(fbf$count)
prop.test(like.n,count)
fbf$condition



