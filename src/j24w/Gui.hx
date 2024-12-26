package j24w;

import update.UpdateBinder;
import ec.CtxWatcher;
import a2d.Widget;
import al.Builder;
import al.core.DataView;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import ec.Entity;
import fancy.domkit.Dkit.BaseDkit;
import fancy.widgets.ProgressBarWidget;
import fu.Signal;
import fu.graphics.ColouredQuad;
import fu.ui.ButtonBase;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import j24w.FishyData;
import j24w.FishyState;
import j24w.Building;
import update.Updatable;

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
    }
}

class BuildingCard extends BaseDkit implements DataView<BuildingDef> {
    static var SRC = <building-card >

        ${fui.quad(__this__.ph, 0xBC007DC0)}
        <label(b().v(pfr, 6).b()) public id="lbl"  style={"small-text"} text={"upgrades"} />
 </building-card>

    public function initData(descr:BuildingDef) {
        lbl.text = descr.name;
    }
}

class BuyBuilding extends BaseDkit {
    @:once var popup:Popup;
    @:once var defs:BuildingsDef;
    @:once var buying:BuyingBilding;

    public var slot:Int;

    var input:a2d.ChildrenPool.DataChildrenPool<BuildingDef, BuildingCard>;

    public var onChoice(default, null) = new IntSignal();

    static var SRC = <buy-building vl={PortionLayout.instance}>
    ${fui.quad(__this__.ph, 0xBC0B0A0A)}
    <popup-title(b().v(sfr, .05).b()) />
    <base(b().v(pfr, 1).b()) id="cardsContainer"  vl={PortionLayout.instance} />

    </buy-building>

    var defIds:Array<String> = [];

    override function init() {
        super.init();
        onChoice.listen(buy);
        input = new fu.ui.InteractivePanelBuilder().withContainer(cardsContainer.c)
            .withWidget(() -> new BuildingCard(b().h(sfr, 0.3).v(sfr, 0.3).b()))
            .withSignal(onChoice)
            .build();
        var defs = defs.getDyn("");
        var dd = [];
        for (f in Reflect.fields(defs)) {
            var d = Reflect.field(defs, f);
            d.name = f;
            dd.push(d);
            defIds.push(f);
        }
        input.initData(dd);
    }

    function buy(i) {
        buying.buy(slot, defIds[i]);
        popup.close();
    }
}

class ProdChainView extends BaseDkit implements DataView<ProductionChain> {
    var progress:ProgressBarWidget;
    var chain:ProductionChain;

    static var SRC = <prod-chain-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xFF00961B)}
            <label(b().v(sfr, 0.03).b()) id="lbl"  style={"fit"} text={"Hi1"} />
            <base(b().l().v(pfr, 1).b()) >
                ${fui.quad(__this__.ph, 0x397A0096)}
                ${progress = new ProgressBarWidget(__this__.ph, 0xff8585)}
            </base>
 </prod-chain-view>

    public function update() {
        progress.setPtogress(chain.getProgress());
    }

    public function initData(descr:ProductionChain) {
        chain = descr;
        var srcLbl = [
        for (sp in chain.receipe.src)
             '${sp.resId} x ${sp.count}'].join(' + ');
        var sp = chain.receipe.out;
        lbl.text = '$srcLbl > ${sp.resId} x ${sp.count}';
    }
}

class BuildingView extends BaseDkit implements Updatable {
    var building:Building;
    var input:a2d.ChildrenPool.DataChildrenPool<ProductionChain, ProdChainView>;

    static var SRC = <building-view vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0xff960000)}
        <label(b().v(pfr, 0.5).b()) id="lbl"  style={"small-text"} text={"Hi1"} />
        <base(b().l().v(pfr, 1).b()) id="chainsContainer" vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0x16C0FFCB)}

        </base>

        <label(b().v(pfr, 0.5).b())  style={"small-text"} text={"Hi1"} />
    </building-view>

    public function update(dt) {
        chainsContainer.c.refresh();
        for (i in 0...building.chains.length)
            input.pool[i].update();
    }

    override function init() {
        super.init();
        input = new fu.ui.InteractivePanelBuilder().withContainer(chainsContainer.c)
            .withWidget(() -> new ProdChainView(b().h(pfr, 1).b()))
            .build();
        if (building != null)
            input.initData(building.chains);
        entity.addComponentByType(Updatable, this);
        new CtxWatcher(UpdateBinder, entity);
    }

    public function initData(building:Building) {
        this.building = building;
        lbl.text = building.name;
        if (!_inited)
            return;
        input.initData(building.chains);
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
        buy.slot = slotId;
        popup.switchTo(buy.ph);
    }

    function onBuildingClick() {
        details.lbl.text = building.name;
        popup.switchTo(details.ph);
    }

    function onSlotChanged() {
        trace("slot changed");
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
