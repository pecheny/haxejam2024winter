package j24w;

import al.Builder;
import al.ec.WidgetSwitcher;
import j24w.FishyState;
import a2d.Widget;
import al.layouts.PortionLayout;
import fancy.domkit.Dkit.BaseDkit;

class GameView extends BaseDkit {
    static var SRC = <game-view vl={PortionLayout.instance}>
        <base(b().v(pfr, 1).b())>
            ${new fancy.widgets.StatsDisplay(__this__.ph); }
        </base>
        <slots-panel(b().v(pfr, 6).b()) id="slots" vl={PortionLayout.instance}   />
    </game-view>
}

@:uiComp("slots-panel")
class SlotsPanel extends BaseDkit {
    var slots:Array<SlotView> = [];
    @:once var state:FishyState;

    static var SRC = <slots-panel vl={PortionLayout.instance}>
    <base(b().v(pfr, .1).h(pfr, .1).b())  hl={PortionLayout.instance}>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
    </base>
    <base(b().v(pfr, .1).h(pfr, .1).b())  hl={PortionLayout.instance}>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
    </base>

    <base(b().v(pfr, .1).h(pfr, .1).b())  hl={PortionLayout.instance}>

        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
    </base>

    </slots-panel>

    override function init() {
        super.init();
        for (i in 0...state.slots.length)
            slots[i].bindSlot(state.slots[i]);
    }
}

class BuildingView extends BaseDkit {
    static var SRC = <building-view >
        ${fui.quad(__this__.ph, 0xff960000)}
        <label(b().v(pfr, 6).b()) id="lbl"  style={"small-text"} text={"Hi1"} />
    </building-view>

    public function initData(building:Building) {
        lbl.text = building.name;
    }
}

class EmptySlot extends BaseDkit {
    static var SRC = <empty-slot >
        ${fui.quad(__this__.ph, 0xff1d1d1d)}
        <label(b().v(pfr, 6).b()) id="lbl"  style={"center"} text={"+"} />
    </empty-slot>
}

class SlotView extends Widget {
    var bv:BuildingView;
    var ev:EmptySlot;
    var slot:Slot;
    var switcher:WidgetSwitcher<Axis2D>;

    public function new(ph) {
        super(ph);
        switcher = new WidgetSwitcher(ph);
    }

    public function bindSlot(slot:Slot) {
        this.slot = slot;
        bv = new BuildingView(Builder.widget());
        ev = new EmptySlot(Builder.widget());
        slot.onChange.listen(onSlotChanged);
        onSlotChanged();
    }

    function onSlotChanged() {
        switch slot.value {
            case Building(b):
                bv.initData(b);
                switcher.switchTo(bv.ph);
            case Empty:
                switcher.switchTo(ev.ph);
        }
    }
}
