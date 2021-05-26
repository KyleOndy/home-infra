# Home Infra

Just the website and base infra for now.

w2: `10.25.89.22`

Using [NixOS](todo) as much as possible.

Goals and Intentions
- Not a reference architecture
- Doing this to learn, and get hands on
- Due to this, things may not be happy-path or idea
- Since this is *home*-lab, on the price-to-performance continuum, I skew towards price.
    - No AWS LBs, or other $$$ services.
    - I tend to bundle more than one service onto a host

Avoiding internet magic and vendor specific implementations.
- Learn how things really work.
- Work with tech and scratch itches I don't get to day-to-day in $JOB_THAT_PAYS_ME


## Current Architecture

- DNS hosted in [Route53](todo)
- An EC2 instance as an apex redirect to homelab
- 


```

|
