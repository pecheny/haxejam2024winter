package j24w;

import fu.bootstrap.ButtonScale;
import j24w.FishyState.AllStats;
import j24w.FishyData.ItemsDef;
import j24w.Perks.ItemsProperty;
import fu.ui.InteractivePanelBuilder;
import fu.Signal.IntSignal;
import al.core.DataView;
import a2d.ChildrenPool.DataChildrenPool;
import j24w.FishyData.PerkUnit;
import Main.Lifecycle;
import al.layouts.PortionLayout;
import ec.Signal;
import fancy.domkit.Dkit;

using a2d.ProxyWidgetTransform;

class GreetView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    @:once var l:Lifecycle;

    static var SRC = <greet-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}
            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"Ok yoy can start yout business on my land. But you should pay with shells you grew. The toll will raise and if you cant afford it one day, I'll throw you out immediately. "} />
            <button(b().v(pfr, 0.1).b()) text={"I'll pay my toll each month as promised."} style={"right"} onClick={done} />

    </greet-view>

    function done() {
        onDone.dispatch();
        // l.showMenu();
    }
}


class GameOverView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    @:once var l:Lifecycle;

    static var SRC = <game-over-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}
            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"game over"} />
            <button(b().v(pfr, 0.1).b()) text={"ok"} style={"center"} onClick={done} />

    </game-over-view>

    function done() {
        // onDone.dispatch();
        l.showMenu();
    }
}

class CheckoutView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    static var SRC = <checkout-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}

            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"month over, toll payed"} />
            <button(b().v(pfr, 0.1).b()) text={"ok"} style={"center"} onClick={done} />
    </checkout-view>

    function done() {
        onDone.dispatch();
    }
}

class ItemCard extends BaseDkit implements DataView<String> {
    static var SRC = <item-card>
        ${fui.quad(__this__.ph.getInnerPh(), 0xBC0F7BFF)}
        <label(b().v(pfr, .3).b()) id="lbl"  color={ 0xecb7b7 } />
    </item-card>

    @:once var defs:ItemsDef;
    @:once var stats:AllStats;

    public function initData(descr:String) {
        var def = defs.get(descr);
        lbl.text = switch def.type {
            case add:
                'Make ${def.value}  ${def.target} more per action.';
            case mp:
                if (stats.keys.contains(def.target))
                    'Produce ${Std.int(def.value * 100)}% more ${def.target}s';
                else
                    '${def.target} ${Std.int(def.value * 100)}% faster.';
        }
        trace(descr);
    }
}

class BuyItem extends BaseDkit {
    static var SRC = <buy-item vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0xBC0E0E0E)}
        <label(b().v(pfr, .3).b()) id="lbl" style={"center"}  text={ "Choose booster:" }  />
        <base(b().v(pfr, 1).b()) id="cardsContainer" layouts={GuiStyles.L_HOR_CARDS}  />
</buy-item>

    public var onChoice(default, null) = new IntSignal();

    var input:DataChildrenPool<String, ItemCard>;
    @:once var items:ItemsProperty;

    override function init() {
        super.init();
        input = new InteractivePanelBuilder().withContainer(cardsContainer.c)
            .withWidget(() -> {
                var mc =
                new ItemCard(b().t(1).h(pfr, 1).v(sfr, 0.3).b());
                new ButtonScale(mc.entity);
                mc;
            })
            .withSignal(onChoice)
            .build();
    }

    public function initChoices(captions:Array<String>) {
        trace(input, captions);
        input.initData(captions);
    }
}
