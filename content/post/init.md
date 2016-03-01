+++
date = "2016-02-29"
title = "init"

+++

I had a desire to play around with some shiny, new tech recently, namely [Docker](https://www.docker.com/), [Kubernetes](http://kubernetes.io/), and [Google Cloud Platform](https://cloud.google.com/). This blog is the early manifestation Docker feels all-consuming in the world of DevOps right now and I am finding myself being ever increasingly convinced that it can be a profoundly powerful approach to running modern software, so I want to take it out for a quick spin. I opted to run my Docker containers on GCP because I already have significant Amazon Web Services experience and wanted something new. Then I needed something to run my containers with; Google open sourced Kubernetes, it seems to have quite a bit of momentum, GCP has a managed Kubernetes service, so I went with that. The only item remaining was something for my containers do.

A static website should be something that is relatively lightweight that I could get up and running quickly. I landed on [Hugo](https://gohugo.io/) as my static website engine. I had already worked with Jekyll a bit, so that could not be a candidate. I am quite intrigued with golang right now, so Hugo has that going for it, and it seems very lightweight and fast. I love that. Hugo it is. Hugo has a built in webserver, but where is the fun in that? I threw [Nginx](https://www.nginx.com/) in the mix for good measure.

Early into getting my hands on Docker, the idea of ultra slim, minimal containers took hold of me and would not relent. [Alpine Linux](http://www.alpinelinux.org/) became my container base. It appears to be extremely slim while maintaining ease of use. Lastly, I tacked on [CoreOS](https://coreos.com/) for my container hosts. It fit with the ultra slim, minimal theme.
