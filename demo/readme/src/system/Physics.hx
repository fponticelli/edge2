package system;

import edge.ItemEntity;
using thx.ReadonlyArray;

class Physics {
  public static function system(x: { property: Point, items: ReadonlyArray<ItemEntity<{ position: Point, velocity: Point }, Component>> }) {
    for(item in x.items) {
      var pos = item.data.position,
          vel = item.data.velocity,
          dx = pos.x + vel.x,
          dy = pos.y + vel.y;
      if(dx <= 0 && vel.x < 0 || dx >= Game.width && vel.x > 0)
        vel.x = -vel.x;
      else
        pos.x = dx;
      if(dy <= 0 && vel.y < 0 || dy >= Game.height && vel.y > 0)
        vel.y = -vel.y;
      else
        pos.y = dy;
      vel.steerToward(pos, x.property, 0.05);
    }
  }
}
