package j24w;

import ec.Component;
import a2d.ProxyWidgetTransform;
import al.prop.ScaleComponent;
import backends.openfl.SpriteAspectKeeper;
import j24w.MainGameplayLoop.SpeedProp;
import a2d.Placeholder2D;
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
    @:once var speed:SpeedProp;

    static var SRC = <game-view vl={PortionLayout.instance}>
    <base(b().v(pfr, 0.5).b()) hl={PortionLayout.instance}>
        <label(b().h(pfr, 0.03).b())  style={"fit"} text={"mnt:"} />
        <label(b().h(pfr, 0.1).b()) public id="month"  style={"right"} text={"1"} />
        <label(b().h(pfr, 0.03).b())  style={"fit"} text={"day:"} />
        <label(b().h(pfr, 0.12).b()) public id="day"  style={"right"} text={""} />
        <label(b().h(pfr, 0.07).b())  style={"fit"} text={"spd:"} />
        <button(b().h(pfr, 0.05).b())  id="spd" onClick={onSpd} text={"1"} style={"fit"}/>
        <base(b().v(pfr, 1).b())>
            ${new fancy.widgets.StatsDisplay(__this__.ph); }
        </base>
        </base>
        <slots-panel(b().v(pfr, 6).b()) id="slots" vl={PortionLayout.instance}   />
    </game-view>

    function onSpd() {
        var sa = speed.value;
        sa++;
        spd.text = speed.value;
    }

    override function init() {
        super.init();
        ph.entity.name = "gui";
        fui.makeClickInput(ph);
    }
}

class BuildingCard extends BaseDkit implements DataView<BuildingDef> {
    var images:BuildingImages;

    static var SRC = <building-card vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0xBC007DC0)}
        <base(b().v(pfr, 0.5).b()) hl={PortionLayout.instance}>
            <label(b().v(pfr, 0.3).b()) public id="name"  style={"fit"} text={"Hi1"} />
            <label(b().h(pfr, 0.5).v(sfr, 0.04).b()) id="lvl"  style={"fit"} text={"Hi1"} />
        </base>
        <base(b().l().v(pfr, 1).b()) >
            ${images = new BuildingImages(__this__.ph)}
        </base>
        <base(b().l().v(pfr, 0.5).b()) id="chainsContainer" vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0x16C0FFCB)}
            <label(b().h(pfr, 0.5).v(sfr, 0.04).b()) id="chains"  style={"fit"} text={"Hi1"} />

        </base>

        <base(b().v(pfr, 0.3).b()) hl={PortionLayout.instance}>
            <label(b().h(pfr, 0.5).v(sfr, 0.04).b())  style={"fit"} text={"price: "} />
            <label(b().v(pfr, 0.3).b()) public id="price"  style={"fit"} text={"Hi1"} />
        </base>
 </building-card>

    public function initData(descr:BuildingDef) {
        name.text = descr.defId;
        if (descr.defId!=null)
            images.switchView(descr.defId);
        lvl.text = "" + descr.curLvl;
        var chainsDesc = "";
        for (ch in descr.actions) {
            var srcLbl = [
                for (sp in ch.src)
                    '${sp.resId} x ${sp.count}'
            ].join(' + ');
            var sp = ch.out;
            chainsDesc += '$srcLbl > ${sp.resId} x ${sp.count} / ${ch.cooldown} s <br/>';
        }
        chains.text = chainsDesc;
        price.text = "" + descr.price[descr.curLvl] + " bucks";
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
        var defsd = defs.getDyn("");
        var dd = [];
        for (f in Reflect.fields(defsd)) {
            var d = defs.getLvl(f, 0);
            d.defId = f;
            // d.name = f;
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
            // ${fui.quad(__this__.ph, 0xFF00961B)}
            // <label(b().v(sfr, 0.03).b()) id="lbl"  style={"fit"} text={"Hi1"} />
            <base(b().l().v(sfr, 0.015).b()) hl={PortionLayout.instance}>
                ${progress = new ProgressBarWidget(__this__.ph, 0xff8585)}

                // <label(b().h(pfr,0.3).v(sfr, 0.03).b()) id="cd"  style={"fit"} text={"Hi1"} />
                // <base(b().l().v(sfr, 0.015).b()) >
                //     ${fui.quad(__this__.ph, 0x397A0096)}
                //     ${progress = new ProgressBarWidget(__this__.ph, 0xff8585)}
                // </base>
            </base>
 </prod-chain-view>

    public function update() {
        progress.setPtogress(chain.getProgress());
    }

    public function initData(descr:ProductionChain) {
        chain = descr;
        // var srcLbl = [
        //     for (sp in chain.receipe.src)
        //         '${sp.resId} x ${sp.count}'
        // ].join(' + ');
        // var sp = chain.receipe.out;
        // lbl.text = '$srcLbl > ${sp.resId} x ${sp.count}';
        // cd.text = "cd: " + chain.receipe.cooldown;
    }
}

class BuildingView extends BaseDkit implements Updatable {
    var building:Building;
    var input:a2d.ChildrenPool.DataChildrenPool<ProductionChain, ProdChainView>;
    var images:BuildingImages;

    static var SRC = <building-view vl={PortionLayout.instance}>
        // ${fui.quad(__this__.ph, 0xff960000)}
        <base(b().v(pfr, 0.5).b()) hl={PortionLayout.instance}>
            <label(b().v(pfr, 0.3).b()) id="name" color={0x190035} style={"fit"} text={"Hi1"} />
            <label(b().h(pfr, 0.5).v(sfr, 0.04).b())  color={0x190035} id="lvl"  style={"fit"} text={"Hi1"} />
        </base>
        <base(b().l().v(pfr, 1).b()) />
        <base(b().l().v(pfr, 0.5).b()) id="chainsContainer" vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0x16C0FFCB)}
        </base>
    </building-view>

    public function update(dt) {
        chainsContainer.c.refresh();
        for (i in 0...building.chains.length)
            input.pool[i].update();
    }

    override function init() {
        super.init();
        images = new BuildingImages(ph);
        input = new fu.ui.InteractivePanelBuilder().withInput((_, _) -> {})
            .withContainer(chainsContainer.c)
            .withWidget(() -> new ProdChainView(b().v(sfr, 0.02).b()))
            .build();
        if (building != null)
            initData(building);
        entity.addComponentByType(Updatable, this);
        new CtxWatcher(UpdateBinder, entity);
        
    }

    public function initData(building:Building) {
        this.building = building;
        name.text = building.defId;
        lvl.text = "" + building.level + " lvl";
        if (!_inited)
            return;
        input.initData(building.chains);
        images.switchView(building.defId);
    }
}

class BuildingImages {
    var images:Map<String, SpriteAspectKeeper> = new Map();
    var ph:Placeholder2D;
    public function new(ph) {
        this.ph = ph;
        addView("farm", new Farm());
        addView("kiosk", new Kiosk());
        addView("garden", new Garden());
        addView("storage", new Kiosk());
    }
    
    function addView(alias, mc) {
        var ak = new SpriteAspectKeeper(Builder.sibling(ph), mc);
        images.set(alias, ak);
        ph.entity.removeChild(ak.entity);
        // ph.entity.addChild(ak.entity);
    }
    
    var active:Entity;

    public function switchView(alias) {
        trace("switch to ", alias);
        if (active!=null)
            ph.entity.removeChild(active);
        trace(alias);
        active = images.get(alias).entity;
        ph.entity.addChild(active);
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
        details.initForSlot(slotId);
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

@:uiComp("popup-title")
class PopupTitle extends BaseDkit {
    @:once var popup:Popup;

    static var SRC = <popup-title hl={PortionLayout.center}>
        ${fui.quad(__this__.ph, 0xFF0087AC)}
        <label(b().h(pfr, 6).b()) public id="lbl"  style={"small-text"} text={"window title"} />
        <button(b().h(sfr, 0.05).b())  style={"center"} onClick={()->popup.close()} text={"X"} />
    </popup-title>
}

class BuildingDetails extends BaseDkit {
    var slotId:Int = -1;
    var slot:Slot;
    var building:Building;
    @:once var buying:BuyingBilding;
    @:once var state:FishyState;
    @:once var popup:Popup;
    @:once var defs:BuildingsDef;

    static var SRC = <building-details vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0xBC0B0A0A)}
        <popup-title(b().v(sfr, .05).b()) id="titlebar" />
        <label(b().v(pfr, .1).b()) public id="lbl"  style={"small-text"} text={"upgrades"} />
        <base(b().v(pfr, 1).h(pfr, .1).b())  hl={PortionLayout.instance}>
            <base(b().v(pfr, 1).h(pfr, .1).b())  />
            <building-card(b().b()) id="current" />
            <base(b().v(pfr, 1).h(pfr, .1).b())  />
            <building-card(b().b()) id="upgraded" />
            <base(b().v(pfr, 1).h(pfr, .1).b())  />
        </base>
        <base(b().v(pfr, .1).h(pfr, .1).b())  hl={PortionLayout.instance}>
            <base(b().v(pfr, 1).h(pfr, .1).b())  />
            <button(b().h(sfr, 0.25).b())  style={"center"} onClick={demolish} text={"demolish"} />
            <base(b().v(pfr, 1).h(pfr, .1).b())  />
            <button(b().h(sfr, 0.25).b())  style={"center"} onClick={()->buying.upgrade(slotId)} text={"upgrade"} />
            <base(b().v(pfr, 1).h(pfr, .1).b())  />
        </base>

    </building-details>

    override function init() {
        super.init();

        if (slotId > 0)
            initForSlot(slotId);
    }

    function demolish() {
        buying.demolish(slotId);
        popup.close();
    }

    public function initForSlot(i) {
        if (slot != null)
            slot.onChange.remove(slotValChanged);
        slotId = i;
        if (!_inited)
            return;
        slot = state.slots[i];
        slot.onChange.listen(slotValChanged);
        slotValChanged();
        titlebar.lbl.text = building.defId + " details";
    }

    function slotValChanged() {
        building = slot.building;
        var def = defs.getLvl(building.defId, building.level);
        def.defId = building.defId;
        current.initData(def);
        current.price.text = "purchased";
        var def = defs.getLvl(building.defId, building.level);
        def.defId = building.defId;
        upgraded.initData(def);
    }
}

@:uiComp("slots-panel")
class SlotsPanel extends BaseDkit {
    var slots:Array<SlotView> = [];
    @:once var state:FishyState;

    static var SRC = <slots-panel vl={PortionLayout.instance}>
    <base(b().v(pfr, .1).h(pfr, .1).b())  layouts={"field"}>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
    </base>
    <base(b().v(pfr, .1).h(pfr, .1).b())  layouts={"field"}>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
        <base(b().v(sfr, .25).h(sfr, .25).b()) > ${slots.push(new SlotView(__this__.ph))} </base>
    </base>

    <base(b().v(pfr, .1).h(pfr, .1).b())  layouts={"field"}>

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
