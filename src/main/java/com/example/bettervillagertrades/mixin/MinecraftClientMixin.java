package com.example.bettervillagertrades.mixin;

import com.example.bettervillagertrades.client.BetterMerchantScreen;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.gui.screen.Screen;
import net.minecraft.client.gui.screen.ingame.MerchantScreen;
import net.minecraft.entity.player.PlayerInventory;
import net.minecraft.screen.MerchantScreenHandler;
import net.minecraft.text.Text;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(MinecraftClient.class)
public class MinecraftClientMixin {
    @Inject(method = "setScreen", at = @At("HEAD"), cancellable = true)
    private void bettervillagertrades$onSetScreen(Screen screen, CallbackInfo ci) {
        if (screen instanceof MerchantScreen merchantScreen) {
            MerchantScreenHandler handler = merchantScreen.getScreenHandler();
            PlayerInventory inventory = MinecraftClient.getInstance().player.getInventory();
            Text title = merchantScreen.getTitle();

            // Replace with our custom screen
            MinecraftClient.getInstance().setScreen(new BetterMerchantScreen(handler, inventory, title));
            ci.cancel();
        }
    }
}
