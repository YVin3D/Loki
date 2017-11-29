# Loki
A Random Number Generator for Metal


## How to Use:

1 - Add the `Loki` folder to your Xcode Project

2 - Include the header in your Metal shader using something like: `#import  "../Loki/loki_header.metal"`

3 - In your shader, initialize a `Loki()` object with (up to) 3 unsigned int seeds. 
** It is recommended to use values that are unique to each thread such as pixel position.

4 - Call `.rand()` on your `Loki` object as many times as you would like.


## Sample Project:

The attached sample project simply creates a scene filled with random grey values generated using Loki. They change every frame using an `iteration` counter that is incremented each frame
