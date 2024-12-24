package j24w;

import ec.Entity;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import fu.ui.ButtonBase;
import al.Builder;
import al.ec.WidgetSwitcher;
import j24w.FishyState;
import a2d.Widget;
import al.layouts.PortionLayout;
import fancy.domkit.Dkit.BaseDkit;
import fu.graphics.ColouredQuad;

class GameView extends BaseDkit {
    @:once var popup:Popup;

    static var SRC = <game-view vl={PortionLayout.instance}>
        <base(b().v(pfr, 1).b())>
            ${new fancy.widgets.StatsDisplay(__this__.ph); }
        </base>
        <slots-panel(b().v(pfr, 6).b()) id="slots" vl={PortionLayout.instance}   />
    </game-view>

    override function init() {
        super.init();
        ph.entity.name = "gui";
        fui.makeClickInput(ph);
        entity.addAliasByName(Entity.getComponentId(BuyBuilding), new BuyBuilding(b().v(sfr, 0.9).v(sfr, 0.9).b()));
        entity.addAliasByName(Entity.getComponentId(BuildingDetails), new BuildingDetails(b().v(sfr, 0.9).h(sfr, 0.9).b()));
    }
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
            slots[i].bindSlot(state.slots[i], i);
    }
}

@:uiComp("popup-title")
class PopupTitle extends BaseDkit {
    @:once var popup:Popup;

    static var SRC = <popup-title hl={PortionLayout.center}>
        ${fui.quad(__this__.ph, 0xFF0087AC)}
        <label(b().h(pfr, 6).b()) id="lbl"  style={"small-text"} text={"window title"} />
        <button(b().h(sfr, 0.05).b())  style={"center"} onClick={()->popup.close()} text={"X"} />
    </popup-title>
}

class BuildingDetails extends BaseDkit {
    static var SRC = <building-details vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0xBC0B0A0A)}
        <popup-title(b().v(sfr, .05).b()) />
        <label(b().v(pfr, 6).b()) public id="lbl"  style={"small-text"} text={"upgrades"} />
        <label(b().v(pfr, 6).b()) style={"small-text"} text={"upgrades"} />
    </building-details>
}

class BuyBuilding extends BaseDkit {
    @:once var popup:Popup;
    static var SRC = <buy-building vl={PortionLayout.instance}>
    ${fui.quad(__this__.ph, 0xBC0B0A0A)}
    <popup-title(b().v(sfr, .05).b()) />
    </buy-building>
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
    @:once var colors:ShapesColorAssigner<ColorSet>;
    @:once var viewProc:ClickViewProcessor;

    static var SRC = <empty-slot>
        ${fui.quad(__this__.ph, 0xff1d1d1d)}
        <label(b().v(pfr, 6).b()) id="lbl"  style={"center"} text={"+"} />
    </empty-slot>

    override function init() {
        super.init();
        viewProc.addHandler(new InteractiveColors(colors.setColor).viewHandler);
    }
}

class SlotView extends Widget {
    var bv:BuildingView;
    var ev:EmptySlot;
    var slot:Slot;
    var slotId:Int;
    var switcher:WidgetSwitcher<Axis2D>;
    var building:Building;
    @:once var popup:Popup;
    @:once var buy:BuyBuilding;
    @:once var details:BuildingDetails;

    public function new(ph) {
        super(ph);
        switcher = new WidgetSwitcher(ph);
    }

    public function bindSlot(slot:Slot, id) {
        this.slot = slot;
        slotId = id;
        bv = new BuildingView(Builder.widget());
        new ButtonBase(bv.ph, onBuildingClick);

        ev = new EmptySlot(Builder.widget());
        new ButtonBase(ev.ph, onEmptyClick);

        slot.onChange.listen(onSlotChanged);
        onSlotChanged();
    }

    function onEmptyClick() {
        popup.switchTo(buy.ph);
    }

    function onBuildingClick() {
        details.lbl.text = building.name;
        popup.switchTo(details.ph);
    }

    function onSlotChanged() {
        switch slot.value {
            case Building(b):
                bv.initData(b);
                building = b;
                switcher.switchTo(bv.ph);
            case Empty:
                building = null;
                switcher.switchTo(ev.ph);
        }
    }
}
