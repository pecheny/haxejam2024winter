package j24w;

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

class GameOverView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    @:once var l:Lifecycle;

    static var SRC = <game-over-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}
            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"game over"} />
            <button(b().v(pfr, 0.1).b()) text={"ok"} onClick={done} />

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
            <button(b().v(pfr, 0.1).b()) text={"ok"} onClick={done} />
    </checkout-view>

    function done() {
        onDone.dispatch();
    }
}

class ItemCard extends BaseDkit implements DataView<String> {
    static var SRC = <item-card>
    ${fui.quad(__this__.ph, 0xBC0F7BFF)}

        <label(b().v(pfr, .3).b()) id="lbl"  color={ 0xecb7b7 } text={ "Choose weapon to attack" }  />
    </item-card>

    public function initData(descr:String) {
        // lbl.text = descr.target + " " + descr.type;
        lbl.text = descr;
        trace(descr);
    }
}

class BuyItem extends BaseDkit {
    static var SRC = <buy-item vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0xBC0E0E0E)}
        <label(b().v(pfr, .3).b()) id="lbl"  color={ 0xecb7b7 } text={ "Choose weapon to attack" }  />
        <base(b().v(pfr, 1).b()) id="cardsContainer" layouts={GuiStyles.L_HOR_CARDS}  />
</buy-item>

    public var onChoice(default, null) = new IntSignal();

    var input:DataChildrenPool<String, ItemCard>;
    @:once var items:ItemsProperty;

    override function init() {
        super.init();
        input = new InteractivePanelBuilder().withContainer(cardsContainer.c)
            .withWidget(() -> new ItemCard(b().h(sfr, 0.3).v(sfr, 0.3).b()))
            .withSignal(onChoice)
            .build();
    }

    public function initChoices(captions:Array<String>) {
        trace(input, captions);
        input.initData(captions);
    }
}
