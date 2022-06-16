package com.twilio.livevideo.app.custom

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View
import androidx.appcompat.widget.Toolbar
import androidx.core.view.isGone
import com.google.android.material.appbar.MaterialToolbar

/**
 * This class is created to fix an issue related to the default toolbar animations when it's navigation between screens.
 */
class FixedToolbar(context: Context, attrs: AttributeSet?) : MaterialToolbar(context, attrs) {
    companion object {
        private val navButtonViewField = Toolbar::class.java.getDeclaredField("mNavButtonView")
            .also { it.isAccessible = true }
    }

    override fun setNavigationIcon(icon: Drawable?) {
        super.setNavigationIcon(icon)
        (navButtonViewField.get(this) as? View)?.isGone = (icon == null)
    }
}