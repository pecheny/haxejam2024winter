package j24w;

import al.Builder;
import al.ec.WidgetSwitcher;

class Popup {
    var switcher:WidgetSwitcher<Axis2D>;
    var empty = Builder.widget();
    var content:WidgetSwitcher<Axis2D>;

    public function new(sw, fui:FuiBuilder) {
        this.switcher = sw;
        content = new WidgetSwitcher(Builder.widget());
        fui.makeClickInput(content.widget());
    }

    public function switchTo(ph) {
        content.switchTo(ph);
        switcher.switchTo(content.widget());
    }

    public function close() {
        switcher.switchTo(empty);
    }
}
