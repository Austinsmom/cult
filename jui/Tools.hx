// misc gui tools

import js.Browser;
import js.html.DivElement;
import js.html.InputElement;

class Tools
{
// compatibility crap - get a target element from event
  public static function getTarget(event): Dynamic
    {
      if (event == null)
        event = untyped __js__("window.event");
      var t = event.target;
      if (t == null)
        t = event.srcElement;
      return t;
    }


// background shadow
  public static function bg(params: Dynamic): DivElement
    {
      if (params.z == null)
        params.z = 15;

      var bg = js.Browser.document.createDivElement();
      bg.style.display = 'none';
      bg.style.position = 'absolute';
      bg.style.zIndex = params.z;
      bg.style.width = params.w;
      bg.style.height = params.h;
      bg.style.left = '0px';
      bg.style.top = '0px';
      bg.style.opacity = '0.8';
      bg.style.background = '#000';
      js.Browser.document.body.appendChild(bg);
      return bg;
    }


// create a button
  public static function button(params: Dynamic): DivElement
    {
      var b = js.Browser.document.createDivElement();
      b.id = params.id;
      b.innerHTML = params.text;
      if (params.bold == null)
        params.bold = true;
      if (params.bold)
        b.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = '20px';
      b.className = 'uiButton';
      b.style.fontSize = params.fontSize;
      b.style.position = 'absolute';
      b.style.width = params.w;
      b.style.height = params.h;
      b.style.left = params.x;
      b.style.top = params.y;
/*
      b.style.background = '#111';
      b.style.border = '1px outset #777';
      b.style.cursor = 'pointer';
      b.style.textAlign = 'center';
*/
      params.container.appendChild(b);
      if (params.func != null)
        b.onclick = params.func;
      if (params.title != null)
        {
          b.title = params.title;
          new JQuery("#" + params.id).tooltip({ delay: 0 });
        }
      return b;
    }


// create close button
  public inline static function closeButton(container: Dynamic, x: Int, y: Int, name: String)
    {
      var b = Tools.button({
        id: name,
        text: "Close",
        width: 80,
        height: 25,
        x: x,
        y: y,
        container: container
        });
      return b;
    }


// create a label
  public static function label(params: Dynamic): DivElement
    {
      var b = js.Browser.document.createDivElement();
      b.id = params.id;
      b.innerHTML = params.text;
      if (params.bold == null)
        params.bold = true;
      if (params.bold)
        b.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = '20px';
      b.style.fontSize = params.fontSize;
      b.style.position = 'absolute';
      b.style.width = params.w;
      b.style.height = params.h;
      b.style.left = params.x;
      b.style.top = params.y;
//      b.style.textAlign = 'center';
      params.container.appendChild(b);
      return b;
    }


// create a window
  public static function window(params: Dynamic): Dynamic
    {
      // center window
      if (params.winW != null)
        params.x = (params.winW - params.w) / 2;
      if (params.winH != null)
        params.y = (params.winH - params.h) / 2;
      if (params.z == null)
        params.z = 10;

      var w = Browser.document.createElement("div");
      w.id = params.id;
      w.style.display = 'none';
      w.style.position = 'absolute';
      w.style.zIndex = params.z;
      w.style.width = params.w;
      w.style.height = params.h;
      w.style.left = params.x;
      w.style.top = params.y;
      if (params.fontSize != null)
        w.style.fontSize = params.fontSize;
      if (params.bold)
        w.style.fontWeight = 'bold';
      w.style.background = '#222';
      w.style.border = '4px double #ffffff';
      Browser.document.body.appendChild(w);

      return w;
    }


// create a textfield
  public static function textfield(params: Dynamic): InputElement
    {
      var t = Browser.document.createInputElement();
      t.id = params.id;
      t.value = params.text;
      if (params.bold == null)
        params.bold = false;
      if (params.bold)
        t.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = '20px';
      t.style.color = '#ffffff';
      t.style.fontSize = params.fontSize;
      t.style.position = 'absolute';
      t.style.width = params.w;
      t.style.height = params.h;
      t.style.left = params.x;
      t.style.top = params.y;
      t.style.background = '#111';
      t.style.paddingLeft = '5px';
      t.style.border = '1px outset #777';
      params.container.appendChild(t);
      return t;
    }


// create a checkbox
  public static function checkbox(params: Dynamic): InputElement
    {
      var t = Browser.document.createInputElement();
      t.id = params.id;
      t.value = params.text;
      t.type = 'checkbox';
      if (params.bold == null)
        params.bold = false;
      if (params.bold)
        t.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = 20;
      t.style.color = '#ffffff';
      t.style.fontSize = params.fontSize;
      t.style.position = 'absolute';
      t.style.width = params.w;
      t.style.height = params.h;
      t.style.left = params.x;
      t.style.top = params.y;
      t.style.background = '#111';
      t.style.paddingLeft = '5px';
      t.style.border = '1px outset #777';
      params.container.appendChild(t);
      return t;
    }
}

