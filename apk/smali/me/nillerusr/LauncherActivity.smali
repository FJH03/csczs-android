.class public Lme/nillerusr/LauncherActivity;
.super Landroid/app/Activity;
.source "LauncherActivity.java"


# static fields
.field static EnvEdit:Landroid/widget/EditText; = null

.field static GamePath:Landroid/widget/EditText; = null

.field public static PKG_NAME:Ljava/lang/String; = null

.field static final REQUEST_PERMISSIONS:I = 0x2a

.field public static can_write:Z

.field static check_updates:Landroid/widget/CheckBox;

.field static cmdArgs:Landroid/widget/EditText;

.field static res_height:Landroid/widget/EditText;

.field static res_width:Landroid/widget/EditText;

.field public static final sdk:I

.field static useVolumeButtons:Landroid/widget/CheckBox;


# instance fields
.field public mPref:Landroid/content/SharedPreferences;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    const/4 v0, 0x1

    sput-boolean v0, Lme/nillerusr/LauncherActivity;->can_write:Z

    const/4 v0, 0x0

    sput-object v0, Lme/nillerusr/LauncherActivity;->GamePath:Landroid/widget/EditText;

    sget-object v0, Landroid/os/Build$VERSION;->SDK:Ljava/lang/String;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    sput v0, Lme/nillerusr/LauncherActivity;->sdk:I

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method

.method public static changeButtonsStyle(Landroid/view/ViewGroup;)V
    .locals 7

    sget v5, Lme/nillerusr/LauncherActivity;->sdk:I

    const/16 v6, 0x15

    if-lt v5, v6, :cond_1

    :cond_0
    return-void

    :cond_1
    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v5

    add-int/lit8 v4, v5, -0x1

    :goto_0
    if-ltz v4, :cond_0

    :try_start_0
    invoke-virtual {p0, v4}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v3

    if-nez v3, :cond_3

    :cond_2
    :goto_1
    add-int/lit8 v4, v4, -0x1

    goto :goto_0

    :cond_3
    instance-of v5, v3, Landroid/view/ViewGroup;

    if-eqz v5, :cond_4

    check-cast v3, Landroid/view/ViewGroup;

    invoke-static {v3}, Lme/nillerusr/LauncherActivity;->changeButtonsStyle(Landroid/view/ViewGroup;)V

    goto :goto_1

    :catch_0
    move-exception v5

    goto :goto_1

    :cond_4
    instance-of v5, v3, Landroid/widget/Button;

    if-eqz v5, :cond_6

    move-object v0, v3

    check-cast v0, Landroid/widget/Button;

    move-object v1, v0

    invoke-virtual {v1}, Landroid/widget/Button;->getBackground()Landroid/graphics/drawable/Drawable;

    move-result-object v2

    if-eqz v2, :cond_5

    const/16 v5, 0x60

    invoke-virtual {v2, v5}, Landroid/graphics/drawable/Drawable;->setAlpha(I)V

    :cond_5
    const/4 v5, -0x1

    invoke-virtual {v1, v5}, Landroid/widget/Button;->setTextColor(I)V

    const/high16 v5, 0x41700000    # 15.0f

    invoke-virtual {v1, v5}, Landroid/widget/Button;->setTextSize(F)V

    invoke-virtual {v1}, Landroid/widget/Button;->getTypeface()Landroid/graphics/Typeface;

    move-result-object v5

    const/4 v6, 0x1

    invoke-virtual {v1, v5, v6}, Landroid/widget/Button;->setTypeface(Landroid/graphics/Typeface;I)V

    goto :goto_1

    :cond_6
    instance-of v5, v3, Landroid/widget/EditText;

    if-eqz v5, :cond_2

    move-object v0, v3

    check-cast v0, Landroid/widget/EditText;

    move-object v1, v0

    const v5, -0xd8d8d9

    invoke-virtual {v1, v5}, Landroid/widget/EditText;->setBackgroundColor(I)V

    const/4 v5, -0x1

    invoke-virtual {v1, v5}, Landroid/widget/EditText;->setTextColor(I)V

    const/high16 v5, 0x41700000    # 15.0f

    invoke-virtual {v1, v5}, Landroid/widget/EditText;->setTextSize(F)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1
.end method

.method public static getAndroidDataDir()Ljava/lang/String;
    .locals 4

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Lme/nillerusr/LauncherActivity;->getDefaultDir()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "/Android/data/"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    sget-object v3, Lme/nillerusr/LauncherActivity;->PKG_NAME:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "/files"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    new-instance v0, Ljava/io/File;

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v2

    if-nez v2, :cond_0

    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    :cond_0
    return-object v1
.end method

.method public static getDefaultDir()Ljava/lang/String;
    .locals 2

    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_1

    :cond_0
    const-string v1, "/sdcard/"

    :goto_0
    return-object v1

    :cond_1
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v1

    goto :goto_0
.end method


# virtual methods
.method public applyPermissions([Ljava/lang/String;I)V
    .locals 4

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    const/4 v0, 0x0

    :goto_0
    array-length v3, p1

    if-ge v0, v3, :cond_1

    aget-object v3, p1, v0

    invoke-virtual {p0, v3}, Lme/nillerusr/LauncherActivity;->checkSelfPermission(Ljava/lang/String;)I

    move-result v3

    if-eqz v3, :cond_0

    aget-object v3, p1, v0

    invoke-interface {v1, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_1
    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_3

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v3

    new-array v2, v3, [Ljava/lang/String;

    const/4 v0, 0x0

    :goto_1
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v3

    if-ge v0, v3, :cond_2

    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    aput-object v3, v2, v0

    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    :cond_2
    invoke-virtual {p0, v2, p2}, Lme/nillerusr/LauncherActivity;->requestPermissions([Ljava/lang/String;I)V

    :cond_3
    return-void
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .locals 12

    const/4 v11, 0x1

    const/4 v10, 0x0

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    invoke-virtual {p0}, Lme/nillerusr/LauncherActivity;->getApplication()Landroid/app/Application;

    move-result-object v5

    invoke-virtual {v5}, Landroid/app/Application;->getPackageName()Ljava/lang/String;

    move-result-object v5

    sput-object v5, Lme/nillerusr/LauncherActivity;->PKG_NAME:Ljava/lang/String;

    invoke-virtual {p0, v11}, Lme/nillerusr/LauncherActivity;->requestWindowFeature(I)Z

    sget v5, Lme/nillerusr/LauncherActivity;->sdk:I

    const/16 v6, 0x15

    if-lt v5, v6, :cond_1

    const v5, 0x1030224

    invoke-super {p0, v5}, Landroid/app/Activity;->setTheme(I)V

    :goto_0
    const-string v5, "mod"

    invoke-virtual {p0, v5, v10}, Lme/nillerusr/LauncherActivity;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v5

    iput-object v5, p0, Lme/nillerusr/LauncherActivity;->mPref:Landroid/content/SharedPreferences;

    const v5, 0x7f030001

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->setContentView(I)V

    const v5, 0x7f06000b

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->findViewById(I)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/LinearLayout;

    const v5, 0x7f06000c

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->findViewById(I)Landroid/view/View;

    move-result-object v5

    check-cast v5, Landroid/widget/EditText;

    sput-object v5, Lme/nillerusr/LauncherActivity;->cmdArgs:Landroid/widget/EditText;

    const v5, 0x7f06000d

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->findViewById(I)Landroid/view/View;

    move-result-object v5

    check-cast v5, Landroid/widget/EditText;

    sput-object v5, Lme/nillerusr/LauncherActivity;->EnvEdit:Landroid/widget/EditText;

    const v5, 0x7f06000e

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->findViewById(I)Landroid/view/View;

    move-result-object v5

    check-cast v5, Landroid/widget/EditText;

    sput-object v5, Lme/nillerusr/LauncherActivity;->GamePath:Landroid/widget/EditText;

    const v5, 0x7f060009

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/Button;

    new-instance v5, Lme/nillerusr/LauncherActivity$1;

    invoke-direct {v5, p0}, Lme/nillerusr/LauncherActivity$1;-><init>(Lme/nillerusr/LauncherActivity;)V

    invoke-virtual {v2, v5}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    const v5, 0x7f060008

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/Button;

    new-instance v5, Lme/nillerusr/LauncherActivity$2;

    invoke-direct {v5, p0}, Lme/nillerusr/LauncherActivity$2;-><init>(Lme/nillerusr/LauncherActivity;)V

    invoke-virtual {v0, v5}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    const v5, 0x7f06000f

    invoke-virtual {p0, v5}, Lme/nillerusr/LauncherActivity;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Landroid/widget/Button;

    new-instance v5, Lme/nillerusr/LauncherActivity$3;

    invoke-direct {v5, p0}, Lme/nillerusr/LauncherActivity$3;-><init>(Lme/nillerusr/LauncherActivity;)V

    invoke-virtual {v3, v5}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    invoke-virtual {p0}, Lme/nillerusr/LauncherActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    const/high16 v6, 0x7f040000

    invoke-virtual {v5, v6}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v4

    sget-object v5, Lme/nillerusr/LauncherActivity;->cmdArgs:Landroid/widget/EditText;

    iget-object v6, p0, Lme/nillerusr/LauncherActivity;->mPref:Landroid/content/SharedPreferences;

    const-string v7, "argv"

    const-string v8, "-nobackgroundlevel -dxlevel 95"

    invoke-interface {v6, v7, v8}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    sget-object v5, Lme/nillerusr/LauncherActivity;->GamePath:Landroid/widget/EditText;

    iget-object v6, p0, Lme/nillerusr/LauncherActivity;->mPref:Landroid/content/SharedPreferences;

    const-string v7, "gamepath"

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Lme/nillerusr/LauncherActivity;->getDefaultDir()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "/srceng"

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-interface {v6, v7, v8}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    sget-object v5, Lme/nillerusr/LauncherActivity;->EnvEdit:Landroid/widget/EditText;

    iget-object v6, p0, Lme/nillerusr/LauncherActivity;->mPref:Landroid/content/SharedPreferences;

    const-string v7, "env"

    const-string v8, "LIBGL_USEVBO=0"

    invoke-interface {v6, v7, v8}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    invoke-virtual {p0}, Lme/nillerusr/LauncherActivity;->getWindow()Landroid/view/Window;

    move-result-object v5

    invoke-virtual {v5}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v5

    check-cast v5, Landroid/view/ViewGroup;

    invoke-static {v5}, Lme/nillerusr/LauncherActivity;->changeButtonsStyle(Landroid/view/ViewGroup;)V

    sget v5, Lme/nillerusr/LauncherActivity;->sdk:I

    const/16 v6, 0x17

    if-lt v5, v6, :cond_0

    const/4 v5, 0x2

    new-array v5, v5, [Ljava/lang/String;

    const-string v6, "android.permission.WRITE_EXTERNAL_STORAGE"

    aput-object v6, v5, v10

    const-string v6, "android.permission.RECORD_AUDIO"

    aput-object v6, v5, v11

    const/16 v6, 0x2a

    invoke-virtual {p0, v5, v6}, Lme/nillerusr/LauncherActivity;->applyPermissions([Ljava/lang/String;I)V

    :cond_0
    return-void

    :cond_1
    const v5, 0x1030005

    invoke-super {p0, v5}, Landroid/app/Activity;->setTheme(I)V

    goto/16 :goto_0
.end method

.method public onPause()V
    .locals 2

    const-string v0, "SRCAPK"

    const-string v1, "onPause"

    invoke-static {v0, v1}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I

    iget-object v0, p0, Lme/nillerusr/LauncherActivity;->mPref:Landroid/content/SharedPreferences;

    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-virtual {p0, v0}, Lme/nillerusr/LauncherActivity;->saveSettings(Landroid/content/SharedPreferences$Editor;)V

    invoke-super {p0}, Landroid/app/Activity;->onPause()V

    return-void
.end method

.method public onRequestPermissionsResult(I[Ljava/lang/String;[I)V
    .locals 2

    const/16 v0, 0x2a

    if-ne p1, v0, :cond_0

    const/4 v0, 0x0

    aget v0, p3, v0

    const/4 v1, -0x1

    if-ne v0, v1, :cond_0

    const v0, 0x7f04000b

    const/4 v1, 0x1

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;II)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    invoke-virtual {p0}, Lme/nillerusr/LauncherActivity;->finish()V

    :cond_0
    return-void
.end method

.method public saveSettings(Landroid/content/SharedPreferences$Editor;)V
    .locals 4

    sget-object v3, Lme/nillerusr/LauncherActivity;->cmdArgs:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    sget-object v3, Lme/nillerusr/LauncherActivity;->GamePath:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    sget-object v3, Lme/nillerusr/LauncherActivity;->EnvEdit:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v3, "argv"

    invoke-interface {p1, v3, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v3, "gamepath"

    invoke-interface {p1, v3, v2}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v3, "env"

    invoke-interface {p1, v3, v1}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    invoke-interface {p1}, Landroid/content/SharedPreferences$Editor;->commit()Z

    return-void
.end method

.method public startSource(Landroid/view/View;)V
    .locals 5

    sget-object v3, Lme/nillerusr/LauncherActivity;->GamePath:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    iget-object v3, p0, Lme/nillerusr/LauncherActivity;->mPref:Landroid/content/SharedPreferences;

    invoke-interface {v3}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-virtual {p0, v0}, Lme/nillerusr/LauncherActivity;->saveSettings(Landroid/content/SharedPreferences$Editor;)V

    sget v3, Lme/nillerusr/LauncherActivity;->sdk:I

    const/16 v4, 0x13

    if-lt v3, v4, :cond_0

    const-string v3, "immersive_mode"

    const/4 v4, 0x1

    invoke-interface {v0, v3, v4}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;

    :goto_0
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    new-instance v2, Landroid/content/Intent;

    const-class v3, Lorg/libsdl/app/SDLActivity;

    invoke-direct {v2, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    const/high16 v3, 0x10000000

    invoke-virtual {v2, v3}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    invoke-virtual {p0, v2}, Lme/nillerusr/LauncherActivity;->startActivity(Landroid/content/Intent;)V

    return-void

    :cond_0
    const-string v3, "immersive_mode"

    const/4 v4, 0x0

    invoke-interface {v0, v3, v4}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;

    goto :goto_0
.end method
